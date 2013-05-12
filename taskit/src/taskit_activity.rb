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

  def get_user_by_id(id)
    for i in 0..(@users.length() - 1)
      Log.d "getUserById", "Looking for id: " + id.to_s + "   Checking index: " + i.to_s
      user_id = @users.get(i).id
      Log.d "getUserById", "User Id is " + user_id.to_s
      if user_id == id
        return @users.get(i)
      end
    end
    nil
  end


  class TaskItAdapter < BaseAdapter
    TAG2 = "TaskItAdapter"
    attr_accessor :context, :data

    class ListItemViewTag
      attr_accessor :task_name, :task_description, :position, :user_name
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
        tag.task_name   = convertView.find_view_by_id(Ruboto::R::id::task_name)
        tag.task_description   = convertView.find_view_by_id(Ruboto::R::id::task_description)
        tag.user_name    = convertView.find_view_by_id(Ruboto::R::id::assignee)
        convertView.set_tag(tag)
      end

      task = get_item(position)
      tag  = convertView.get_tag

      tag.task_name.set_text(task.name)
      tag.task_description.set_text(task.details)
      user = @context.get_user_by_id(task.user_id)
      if user
        tag.user_name.set_text(user.name)
      end

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
      if users
        users.each do |user|
          @users.add User.new( user['id'], user['name'], user['email_address'] )
        end
      end


      tasks = get_json_from_url('http://192.168.252.129:3000/tasks.json')
      @tasks.clear
      if tasks
        tasks.each do |task|
          new_task = Task.new(task['id'], task['name'], task['details'], task['user_id'])
          Log.e "Adding Task", new_task.inspect
          @tasks.add new_task
        end
      end

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
        Log.e "Parsed Json", json_array.to_s
      rescue
        Log.e 'Parse Error', 'Error parsing data'
      end

      json_array

    end
  end
end

