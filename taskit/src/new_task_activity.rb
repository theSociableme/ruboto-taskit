require 'ruboto/widget'
require 'ruboto/util/toast'
require 'user'
require 'task'
require 'multi_json'
require 'net/http'

ruboto_import_widgets :Button, :LinearLayout, :TextView, :EditText, :Spinner, :SpinnerAdapter

# http://xkcd.com/378/

class NewTaskActivity
  def onCreate(bundle)
    super
    set_title 'New Task'
    Log.e 'USERS', $users.to_string

    @new_task = Task.new(nil, nil, nil, nil)
    @new_task.user_id = $users.get(0).id

    @adapter = UserSpinner.new(self, $users)
    self.content_view =
        linear_layout :orientation => :vertical do
          @text_view = text_view :text => 'New Task', :id => 42, :width => :match_parent,
                                 :gravity => :center, :text_size => 32.0
          @task_name = edit_text :text => 'Name', :width => :match_parent
          @task_details = edit_text :text => 'Details', :width => :match_parent
          @spinner = spinner :adapter => @adapter, :on_item_selected_listener => ItemSelectedListener.new(self, @new_task), :prompt => 'Select a User'
          @spinner.adapter = @adapter
          button :text => 'Add Task', :width => :match_parent, :id => 43, :on_click_listener => proc { submit_new_task }
        end
  rescue
    puts "Exception creating activity: #{$!}"
    puts $!.backtrace.join("\n")
  end

  def task_submitted
    finish()
  end

  private


  def submit_new_task
    toast 'Submitting'

    @new_task.name = @task_name.get_text.to_string
    @new_task.details = @task_details.get_text.to_string

    task_submitter = TaskSubmitter.new(self, @new_task)
    task_submitter.execute

  end



  class ItemSelectedListener
    def initialize(activity, new_task)
      @new_task = new_task
      @activity = activity
    end

    def onItemSelected(spinner, view, position, id)
      if position != 0
        @new_task.user_id = spinner.getSelectedItem.id
      end
    end
  end

  class UserSpinner
    include SpinnerAdapter

    TAG2 = "UserSpinner"
    attr_accessor :context, :data

    class ListItemViewTag
      attr_accessor :title, :name, :position
    end

    def initialize(context, data)
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

    def getItemViewType(position)
      Ruboto::R::layout::user_spinner_item
    end

    def hasStableIds
      return true
    end

    def getView(position, convertView, parent)
      Log.d TAG2, 'GET VIEW'
      if convertView == nil
        convertView = LayoutInflater.from(@context).inflate(Ruboto::R::layout::user_spinner_item, nil)
        tag         = ListItemViewTag.new
        tag.name    = convertView.find_view_by_id(Ruboto::R::id::name)
        convertView.set_tag(tag)
      end

      task = getItem(position)
      tag  = convertView.get_tag

      tag.name.set_text(task.name)

      convertView
    end

    def getDropDownView(position, convertView,parent)
        getView(position, convertView, parent)
    end

    def isEmpty
      false
    end

    def registerDataSetObserver(observer)

    end

    def unregisterDataSetObserver(observer)

    end
  end

  class TaskSubmitter < android.os.AsyncTask
    TAG3 = 'TaskFetcher'

    def initialize(context, new_task)
      super()
      @context = context
      @new_task = new_task
      Log.d TAG3, 'Initialize'
    end

    def doInBackground(*param)

      Log.d TAG3, 'doInBackground'

      Log.e "NEW TASK JSON", @new_task.to_json

      req = Net::HTTP::Post.new('/tasks', initheader = { 'Content-Type' => 'application/json' } )
      req.body = @new_task.to_json
      response = Net::HTTP.new('192.168.252.129','3000').start {|http| http.request(req) }

      Log.e "Response", response.inspect
      response
    end

    def onPostExecute(param)
      Log.d TAG3, 'onPostExecute'

      @context.task_submitted
    end

  end
end
