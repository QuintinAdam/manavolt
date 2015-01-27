# By default Volt generates this controller for your Main component
class MainController < Volt::ModelController
  ####teams

  # def index
  #   # Add code for when the index view is loaded
  # end

  def teams
    self.model = :store
  end

  def add_team
    self._teams << page._new_team
    page._new_team = {}
  end

  def remove_team(team)
    _teams.delete(team)
  end

  def show
    store._teams.find(_id: params._id).then do |results|
      #self is important
      self.model = results[0]
    end
    # page._new_task_repeatable = ''
    # page._new_task_daily = ''
    # page._new_task_todo = ''
  end
  ###tasks

  def repeatable_tasks
    self.model._tasks.find({ task_type: 'repeatable'})
  end

  def add_task_repeatable
    buffy = self.model.buffer
    buffy._tasks << {name: page._new_task_repeatable, task_type: "repeatable"}
    buffy.save!
    page._new_task_repeatable = ''
  end

  def daily_tasks
    self.model._tasks.find({ task_type: 'daily'})
  end

  def add_task_daily
    buffy = self.model.buffer
    buffy._tasks  << {name: page._new_task_daily, task_type: "daily"}
    buffy.save!
    page._new_task_daily = ''
  end

  def todo_tasks
    self.model._tasks.find({ task_type: 'todo'})
  end

  def add_task_todo
    buffy = self.model.buffer
    buffy._tasks << {name: page._new_task_todo, task_type: "todo"}
    buffy.save!
    page._new_task_todo = ''
  end

  def remove_task(task)
    buffy = self.model.buffer
    buffy._tasks.delete(task)
    buffy.save!
  end

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
