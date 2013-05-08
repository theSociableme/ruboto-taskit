require 'ruboto/activity'
require 'ruboto/widget'
require 'ruboto/util/toast'
require 'task'
require 'person'

ruboto_import_widgets :Button, :LinearLayout, :RelativeLayout, :TextView, :ListView

java_import "android.util.Log"
java_import "android.widget.ArrayAdapter"
java_import "android.widget.BaseAdapter"
java_import "java.util.ArrayList"
java_import "android.view.LayoutInflater"
#java_import "android.os.AsyncTask"

class TaskitActivity
    TAG = "TaskitActivity"

  def onCreate(bundle)
    super
    Log.d(TAG, "****************************************************************************")
    Log.d(TAG, "****************************************************************************")
    Log.d "TaskitActivity", "in onCreate"
    Log.d(TAG, "****************************************************************************")
    Log.d(TAG, "****************************************************************************")
    set_title 'Ruboto - Task It'

    task = Task.new("Hello World")

    @tasks = ArrayList.new
    @tasks.add task

    @adapter = TaskItAdapter.new(self, @tasks)


    Log.d(TAG, "****************************************************************************")
    Log.d(TAG, "****************************************************************************")
    Log.e "TaskitActivity", "created adapter"
    Log.d(TAG, "****************************************************************************")
    Log.d(TAG, "****************************************************************************")
    self.setContentView(Ruboto::R::layout::task_list)
    new_task_button = findViewById(Ruboto::R::id::new_task_button)
    @task_list = findViewById(Ruboto::R::id::task_list)
    @task_list.set_adapter(@adapter)
    new_task_button.on_click_listener = proc { |view| new_task_activity }
    Log.d(TAG, "****************************************************************************")
    Log.d(TAG, "****************************************************************************")
    Log.e "TaskitActivity", "finished onCreate"
    Log.d(TAG, "****************************************************************************")
    Log.d(TAG, "****************************************************************************")
  rescue
    puts "Exception creating activity: #{$!}"
    puts $!.backtrace.join("\n")
  end

  def onResume
    super
    tip_updater = TaskFetcher.new
    tip_updater.execute
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
      @data = data
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
        tag = ListItemViewTag.new
        tag.title = convertView.findViewById(Ruboto::R::id::task)
        tag.name = convertView.findViewById(Ruboto::R::id::assignee)
        convertView.setTag(tag)
      end

      task = getItem(position)
      tag = convertView.getTag()

      tag.title.setText(task.description)

      convertView
    end

  end

  class TaskFetcher < android.os.AsyncTask #.<java.lang.Void, java.lang.Void, java.lang.Void>
    TAG3 = "TaskFetcher"

    def initialize
      super()
      Log.d(TAG3, "TaskFetcher Initialize")
      #@context = context
    end

    def onPreExecute(param)
      Log.d(TAG3, "TaskFetcher onPreExecute")
    end

    def doInBackground(*param)

      Log.d(TAG3, "TaskFetcher doInBackground")

    end

    def onPostExecute(param)
      Log.d(TAG3, "TaskFetcher onPostExecute")
    end
  end

end
