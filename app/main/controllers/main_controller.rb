# By default Volt generates this controller for your Main component
class MainController < Volt::ModelController
  ####teams

  # def index
  #   # Add code for when the index view is loaded
  # end

  def teams
    self.model = :store
  end

  def show
    store._teams.find(_id: params._id).then do |results|
      #self is important
      self.model = results[0]
      # self.model._tasks.size
    end
    # page._new_task_repeatable = ''
    # page._new_task_daily = ''
    # page._new_task_todo = ''
  end

  def add_team
    self._teams << page._new_team
    page._new_team = {}
  end

  # def remove_team(team)
  #   _teams.delete(team)
  # end

  ###tasks

  def add_task_repeatable
    _tasks << {name: page._new_task_repeatable, task_type: "repeatable"}
    self.model.buffer.save!
    page._new_task_repeatable = ''
  end

  # def add_task_daily
  #   _tasks << {name: page._new_task_daily, task_type: "daily"}
  #   model.buffer.save!
  #   page._new_task_daily = ''
  # end

  # def add_task_todo
  #   _tasks << {name: page._new_task_todo, task_type: "todo"}
  #   model.buffer.save!
  #   page._new_task_todo = ''
  # end

  # def remove_task(task)
  #   model._tasks.delete(task)
  # end

  def about
    # Add code for when the about view is loaded
  end

  def options
    vals = page._opts.to_s.or('').split(/,/)

    return vals
  end

  private

  # The main template contains a #template binding that shows another
  # template.  This is the path to that template.  It may change based
  # on the params._controller and params._action values.
  def main_path
    params._controller.or('main') + '/' + params._action.or('index')
  end

  # Determine if the current nav component is the active one by looking
  # at the first part of the url against the href attribute.
  def active_tab?
    url.path.split('/')[1] == attrs.href.split('/')[1]
  end
end
