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
    #adapter = ArrayAdapter.new(self, Ruboto::R::layout::task_list_item)
    #adapter.add("Test")

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


  def new_task_activity
    start_ruboto_activity :class_name => "NewTaskActivity"
  end

  def load_task_list

  end

  class TaskItAdapter < android.widget.BaseAdapter
      TAG2 = "TaskItAdapter"

    def initialize(context, data)
      Log.d(TAG2, "****************************************************************************")
      Log.d(TAG2, "****************************************************************************")
      Log.d(TAG2, "                 Initialize       ")
      Log.d(TAG2, "****************************************************************************")
      Log.d(TAG2, "****************************************************************************")
      @context = context
      @data = data
    end

    def getCount
      Log.d(TAG2, "****************************************************************************")
      Log.d(TAG2, "****************************************************************************")
      Log.d(TAG2, "                 Get Count          ")
      Log.d(TAG2, "****************************************************************************")
      Log.d(TAG2, "****************************************************************************")

      @data.size
    end

    def getItem(position)
      Log.d(TAG2, "****************************************************************************")
      Log.d(TAG2, "****************************************************************************")
      Log.d(TAG2, "                 GET ITEM       ")
      Log.d(TAG2, "****************************************************************************")
      Log.d(TAG2, "****************************************************************************")
      @data.get(position)
    end

    def getItemId(position)
      Log.d(TAG2, "****************************************************************************")
      Log.d(TAG2, "****************************************************************************")
      Log.d(TAG2, "                 GET ITEMID           ")
      Log.d(TAG2, "****************************************************************************")
      Log.d(TAG2, "****************************************************************************")
      position
    end

    def hasStableIds
      return true
    end

    def getView(position, convertView, parent)
      Log.d(TAG2, "****************************************************************************")
      Log.d(TAG2, "****************************************************************************")
      Log.d(TAG2, "                 GET VIEW           ")
      Log.d(TAG2, "****************************************************************************")
      Log.d(TAG2, "****************************************************************************")
      if convertView == null
        convertView = LayoutInflater.from(@context).inflate(Ruboto::R::id::task_list_item, null)
        tag = ListItemViewTag.new
        tag.title = convertView.findViewById(R.id.task)
        tag.name = convertView.findViewById(R.id.assignee)
        convertView.setTag(tag)
      end

      task = getItem(position)
      tag = convertView.getTag()

      tag.title.setText(task.description)

      convertView
    end

  end

end
