require 'ruboto/activity'
require 'ruboto/widget'
require 'ruboto/util/toast'
require 'jsonable'
require 'task'
require 'user'
require 'multi_json'


ruboto_import_widgets :Button, :LinearLayout, :RelativeLayout, :TextView, :ListView, :ArrayAdapter, :BaseAdapter

java_import 'android.util.Log'

java_import 'java.util.ArrayList'
java_import 'android.view.LayoutInflater'
java_import 'android.os.AsyncTask'
java_import 'org.apache.http.client.HttpClient'
java_import 'org.apache.http.impl.client.DefaultHttpClient'
java_import 'org.apache.http.client.methods.HttpGet'
java_import 'java.io.BufferedReader'
java_import 'java.lang.StringBuilder'
java_import 'java.io.InputStreamReader'
java_import 'org.json.JSONArray'

class TaskitActivity
  TAG = 'TaskitActivity'
  attr_accessor :tasks, :users


  def on_create(bundle)
    super
    set_title 'Ruboto Taskit'
    Log.d TAG, "in onCreate"

    @users = ArrayList.new
    @tasks = ArrayList.new

    set_title 'Ruboto - Task It'
    @adapter = TaskItAdapter.new(self, @tasks)

    Log.e TAG, "created adapter"

    self.setContentView(Ruboto::R::layout::task_list)
    new_task_button = findViewById(Ruboto::R::id::new_task_button)
    @task_list      = findViewById(Ruboto::R::id::task_list)
    @task_list.set_adapter(@adapter)
    new_task_button.on_click_listener = proc { |view| new_task_activity }

    Log.e TAG, "finished onCreate"

  rescue
    puts "Exception creating activity: #{$!}"
    puts $!.backtrace.join("\n")
  end

  def on_resume
    super
    task_fetcher = TaskFetcher.new(@users, @tasks, @adapter)
    task_fetcher.execute
  end

  def new_task_activity
    $users = @users
    start_ruboto_activity :class_name => "NewTaskActivity"
  end

  def load_task_list

  end

  class TaskItAdapter < BaseAdapter
    TAG2 = "TaskItAdapter"
    attr_accessor :context, :data

    class ListItemViewTag
      attr_accessor :title, :name, :position
    end

    def initialize(context, data)
      super()
      Log.d TAG2, 'Initialize'
      @context = context
      @data    = data
    end

    def getCount
      Log.d TAG2, 'Get Count'
      @data.size
    end

    def getItem(position)
      Log.d TAG2, 'GET ITEM'
      @data.get(position)
    end

    def getItemId(position)
      Log.d TAG2, 'GET ITEMID'
      position
    end

    def hasStableIds
      return true
    end

    def getView(position, convertView, parent)
      Log.d TAG2, 'GET VIEW'
      if convertView == nil
        convertView = LayoutInflater.from(@context).inflate(Ruboto::R::layout::task_list_item, nil)
        tag         = ListItemViewTag.new
        tag.title   = convertView.find_view_by_id(Ruboto::R::id::task)
        tag.name    = convertView.find_view_by_id(Ruboto::R::id::assignee)
        convertView.set_tag(tag)
      end

      task = get_item(position)
      tag  = convertView.get_tag

      tag.title.set_text(task.description)

      convertView
    end

  end

  class TaskFetcher < android.os.AsyncTask #.<java.lang.Void, java.lang.Void, java.lang.Void>
    TAG3 = 'TaskFetcher'

    def initialize(users, tasks, adapter)
      super()
      @users = users
      @tasks = tasks
      @adapter = adapter
      Log.d TAG3, 'Initialize'
    end

    def onPreExecute(param)
      toast 'Loading....'
      Log.d TAG3, 'onPreExecute'
    end

    def doInBackground(*param)

      Log.d TAG3, 'doInBackground'
      users = get_json_from_url('http://192.168.252.129:3000/users.json')
      @users.clear
      users.each do |user|
        @users.add User.new( user['id'], user['name'], user['email_address'] )
      end

      #for i in 0..(users.length() - 1)
      #  user = users.get_json_object(i)
      #  Log.d TAG3, user.to_string
      #  @users.add User.new(user.get_string('name'), user.get_string('email_address'))
      #end
      tasks = get_json_from_url('http://192.168.252.129:3000/tasks.json')
      @tasks.clear
      tasks.each do |task|
        @tasks.add Task.new(task['id'], task['name'], task['details'])
      end


      #for i in 0..(tasks.length() - 1)
      #  task = tasks.get_json_object(i)
      #  Log.d TAG3, task.to_string
      #  @tasks.add Task.new(task.get_string('details'))
      #end
    end

    def onPostExecute(param)
      Log.d TAG3, 'onPostExecute'
      @adapter.notify_data_set_changed
    end

    def get_json_from_url(url)


      begin
        httpclient = DefaultHttpClient.new()
        httpget   = HttpGet.new(url)
        response   = httpclient.execute(httpget)
        entity     = response.entity
        is         = entity.content

      rescue
        Log.e 'Network Error', 'Error in http connection'
      end

      begin
        reader = BufferedReader.new(InputStreamReader.new(is, "iso-8859-1"), 8)
        sb     = StringBuilder.new()
        line   = nil
        while ((line = reader.read_line) != nil)
          sb.append(line + "\n")
        end
        is.close
        result=sb.to_string
      rescue
        Log.e 'Data Error', 'Error converting result'
      end

      #try parse the string to a JSON object
      begin
        json_array = MultiJson.decode(result)
      rescue
        Log.e 'Parse Error', 'Error parsing data'
      end

      json_array

    end
  end
end

