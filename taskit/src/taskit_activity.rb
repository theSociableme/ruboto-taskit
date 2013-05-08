require 'ruboto/activity'
require 'ruboto/widget'
require 'ruboto/util/toast'
require 'task'
require 'user'

ruboto_import_widgets :Button, :LinearLayout, :RelativeLayout, :TextView, :ListView

java_import "android.util.Log"
java_import "android.widget.ArrayAdapter"
java_import "android.widget.BaseAdapter"
java_import "java.util.ArrayList"
java_import "android.view.LayoutInflater"
java_import "android.os.AsyncTask"
java_import "org.apache.http.client.HttpClient"
java_import "org.apache.http.impl.client.DefaultHttpClient"
java_import "org.apache.http.client.methods.HttpGet"
java_import "java.io.BufferedReader"
java_import "java.lang.StringBuilder"
java_import "java.io.InputStreamReader"
java_import "org.json.JSONArray"

class TaskitActivity
  TAG = "TaskitActivity"
  attr_accessor :tasks, :users

  #def self.tasks
  #  @tasks ||= ArrayList.new
  #end
  #
  #def self.users
  #  @users ||= ArrayList.new
  #end
  #
  #def self.adapter
  #  @adapter ||= TaskItAdapter.new(self, self.tasks)
  #end

  def onCreate(bundle)
    super

    Log.d "TaskitActivity", "in onCreate"

    @users = ArrayList.new
    @tasks = ArrayList.new

    set_title 'Ruboto - Task It'
    @adapter = TaskItAdapter.new(self, @tasks)

    Log.e "TaskitActivity", "created adapter"

    self.setContentView(Ruboto::R::layout::task_list)
    new_task_button = findViewById(Ruboto::R::id::new_task_button)
    @task_list      = findViewById(Ruboto::R::id::task_list)
    @task_list.set_adapter(@adapter)
    new_task_button.on_click_listener = proc { |view| new_task_activity }

    Log.e "TaskitActivity", "finished onCreate"

  rescue
    puts "Exception creating activity: #{$!}"
    puts $!.backtrace.join("\n")
  end

  def onResume
    super
    task_fetcher = TaskFetcher.new(@users, @tasks, @adapter)
    task_fetcher.execute
  end

  def new_task_activity
    start_ruboto_activity :class_name => "NewTaskActivity"
  end

  def load_task_list

  end

  class TaskItAdapter < android.widget.BaseAdapter
    TAG2 = "TaskItAdapter"
    attr_accessor :context, :data

    class ListItemViewTag
      attr_accessor :title, :name, :position
    end

    def initialize(context, data)
      super()
      Log.d(TAG2, "                 Initialize       ")
      @context = context
      @data    = data
    end

    def getCount
      Log.d(TAG2, "                 Get Count          ")
      @data.size
    end

    def getItem(position)
      Log.d(TAG2, "                 GET ITEM       ")
      @data.get(position)
    end

    def getItemId(position)
      Log.d(TAG2, "                 GET ITEMID           ")
      position
    end

    def hasStableIds
      return true
    end

    def getView(position, convertView, parent)
      Log.d(TAG2, "                 GET VIEW           ")
      if convertView == nil
        convertView = LayoutInflater.from(@context).inflate(Ruboto::R::layout::task_list_item, nil)
        tag         = ListItemViewTag.new
        tag.title   = convertView.findViewById(Ruboto::R::id::task)
        tag.name    = convertView.findViewById(Ruboto::R::id::assignee)
        convertView.setTag(tag)
      end

      task = getItem(position)
      tag  = convertView.getTag()

      tag.title.setText(task.description)

      convertView
    end

  end

  class TaskFetcher < android.os.AsyncTask #.<java.lang.Void, java.lang.Void, java.lang.Void>
    TAG3 = "TaskFetcher"

    def initialize(users, tasks, adapter)
      super()
      @users = users
      @tasks = tasks
      @adapter = adapter
      Log.d(TAG3, "TaskFetcher Initialize")
      #@context = context
    end

    def onPreExecute(param)
      Log.d(TAG3, "TaskFetcher onPreExecute")
    end

    def doInBackground(*param)

      Log.d(TAG3, "TaskFetcher doInBackground")
      users = getJSONfromURL('http://192.168.252.129:3000/users.json')
      for i in 0..(users.length() - 1)
        user = users.getJSONObject(i)
        Log.d(TAG3, user.toString)
        @users.add User.new(user.getString("name"), user.getString("email_address"))
      end
      tasks = getJSONfromURL('http://192.168.252.129:3000/tasks.json')
      for i in 0..(tasks.length() - 1)
        task = tasks.getJSONObject(i)
        Log.d(TAG3, task.toString)
        @tasks.add Task.new(task.getString("details"))
      end
    end

    def onPostExecute(param)
      Log.d(TAG3, "TaskFetcher onPostExecute")
      @adapter.notifyDataSetChanged
    end

    def getJSONfromURL(url)


      #begin
        httpclient = DefaultHttpClient.new()
        httpget   = HttpGet.new(url)
        response   = httpclient.execute(httpget)
        entity     = response.getEntity()
        is         = entity.getContent()

      #rescue
      #  Log.e("log_tag", "Error in http connection ")
      #end

      #begin
        reader = BufferedReader.new(InputStreamReader.new(is, "iso-8859-1"), 8)
        sb     = StringBuilder.new()
        line   = nil
        while ((line = reader.readLine()) != nil)
          sb.append(line + "\n")
        end
        is.close()
        result=sb.toString()
      #rescue
      #  Log.e("log_tag", "Error converting result ")
      #end

      #try parse the string to a JSON object
      #begin
        jArray = JSONArray.new(result)
      #rescue
      #  Log.e("log_tag", "Error parsing data ")
      #end

      jArray

    end
  end
end

