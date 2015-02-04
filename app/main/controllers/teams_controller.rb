class TeamsController < Volt::ModelController
  model :store # allows us to use _teams instead of page._teams

  def index
  end

  def show
    _teams.find(_id: params._id).then do |results|
      self.model = results[0]

      # clears out unsaved edits on load
      self.model._dailys.find(editing: true).then do |edit_results|
        edit_results.each do |daily|
          daily.editing = false
        end
      end
    end
  end

  private

  def add_team
    _teams << { name: page._new_team, level: 1, experience: 0, health: 50, mana: 0 }
    page._new_team = ''
  end

  def remove_team(team)
    remove_team_repeatables(team)
    remove_team_dailys(team)
    remove_team_todos(team)
    _teams.delete(team)
  end

  def remove_team_repeatables(team)
    team._repeatables.size
    r = team._repeatables.map{|x|x}
    r.each do |repeat|
      puts "repeat #{repeat} deleted"
      _repeatables.delete(repeat)
    end
  end

  def remove_team_dailys(team)
    team._dailys.size
    d = team._dailys.map{|x|x}
    d.each do |daily|
      _dailys.delete(daily)
    end
  end

  def remove_team_todos(team)
    team._todos.size
    t = team._todos.map{|x|x}
    t.each do |todo|
      _todos.delete(todo)
    end
  end

  def end_of_day(team)
    # team._todos.size
    # team._dailys.size
    # team._repeatables.size
    team._todos.each do |todo|
      if !todo.completed
        todo.score -= todo.difficulty
      end
      # if past due_date lower hp
    end
    team._dailys.each do |daily|
      if daily.completed == true
        daily.score += daily.difficulty
        daily.completed = false
      else
        daily.score -= daily.difficulty
        remove_health(3 * daily.difficulty)
      end
    end
    team._repeatables.each do |repeat|
      repeat.score -= repeat.difficulty # minus 1 2 or 3 based on difficulty
    end
  end

  #### Repeatable

  def add_repeatable
    _repeatables << {name: page._repeatable_name, team_id: self.model.__id, score: 0, difficulty: 1, completed: false}
    add_event_log('Added repeatable: ' + page._repeatable_name, 'info')
    page._repeatable_name = ''
  end

  def remove_repeat(repeat)
    add_event_log('Removed repeatable: ' + repeat.name, 'danger')
    _repeatables.delete(repeat)
  end

  def did_positive_task(repeat)
    add_event_log('#winning. Task completed: ' + repeat.name, 'success')
    repeat.score += 1
    add_experience(level_modifier * repeat.difficulty )
    add_mana(5 * repeat.difficulty)
  end

  def did_negative_task(repeat)
    add_event_log('Sucked at life. Task Failed: ' + repeat.name, 'warning')
    repeat.score -= 1
    remove_health(3 * repeat.difficulty)
  end

  # this totally does not work... ='(
  # def push_to_repeat_top(repeat)
  #   _repeatables.delete(repeat)
  #   _repeatables.insert(0, repeat) # can't use unshift
  # end


  #### Daily

  def add_daily
    _dailys << {name: page._daily_name, team_id: self.model.__id, difficulty: 1, editing: false, score: 0, streak: 0, completed: false}
    add_event_log('Added daily: ' + page._daily_name, 'info')
    page._daily_name = ''
  end

  def remove_daily(daily)
    add_event_log('Removed daily: ' + daily.name, 'danger')
    _dailys.delete(daily)
  end

  def daliy_completed(daily)
    add_event_log('Completed daily: ' + daily.name, 'success')
    daily.completed = true
    add_experience(level_modifier * daily.difficulty )
    add_mana(5 * daily.difficulty)
  end

  # experience and mana gain based on difficulty
  # def daily_difficulty_mod
  # end

  def daliy_uncompleted(daily)
    add_event_log('Uncompleted daily: ' + daily.name, 'warning')
    daily.completed = false
    remove_experience(level_modifier)
    remove_mana(5 * daily.difficulty)
  end

  def editing_daily(daily)
    if daily.editing == true
      daily.editing = false
    else
      daily.editing = true
      page._task_name = daily.name
    end
  end

  def save_daily(daily)
    daily.name = page._task_name
    daily.editing = false
  end

  def current_difficulty(daily, val)
    true if daily.difficulty == val
  end

  def set_daily_difficulty(daily, val)
    daily.difficulty = val
  end

  #### Todo

  def add_todo
    _todos << {name: page._todo_name, team_id: self.model.__id, score: 0, difficulty: 1, completed: false}
    add_event_log('Added a new todo: ' + page._todo_name, 'info')
    page._todo_name = ''
  end

  def remove_todo(todo)
    add_event_log('Deleted todo: ' + todo.name, 'danger')
    _todos.delete(todo)
  end

  def todo_completed(todo)
    add_event_log('Completed todo: ' + todo.name, 'success')
    todo.completed = true
    add_experience(level_modifier * todo.difficulty )
    add_mana(5 * todo.difficulty)
  end

  def todo_uncompleted(todo)
    add_event_log('Uncompleted todo: ' + todo.name, 'warning')
    todo.completed = false
    remove_experience(level_modifier)
    remove_mana(5 * todo.difficulty)
  end

  def todo_completed_count
    _todos.count { |t| t._completed }
  end

  def to_do_incomplete_count
    _todos.size - todo_completed_count
  end
  ####
  def set_score_class_name(task)
    task_score = task.score
    if task_score.between?(-1000, -26)
      task.score_class_name = 'much-fail-you-have'
    elsif task_score.between?(-26, -16)
      task.score_class_name = 'failing-harder'
    elsif task_score.between?(-16, -6)
      task.score_class_name = 'failing'
    elsif task_score.between?(-6, 6)
      task.score_class_name = 'neutral-like-switzerland'
    elsif task_score.between?(6, 16)
      task.score_class_name = 'passing'
    elsif task_score.between?(16, 26)
      task.score_class_name = 'passing-like-a-boss'
    else
      task.score_class_name = 'u-so-good'
    end
  end
  #### Dashboard || Leveling System

  def add_mana(val)
    self.model._mana += val
  end

  def remove_mana(val)
    self.model._mana -= val
  end

  def get_health_percent
    (_health.inspect.to_i / 50) * 100
  end

  def add_health(val)
    self.model._health += val
  end

  def remove_health(val)
    self.model._health -= val
    death_from_above if _health <= 0
  end

  def add_experience(val)
    self.model._experience += val
    if _experience >= level_cap
      went_over = _experience - level_cap
      level_up_boiii(went_over)
    end
  end

  def remove_experience(val)
    self.model._experience -= val
  end

  def level_modifier
    (_level.inspect.to_i * 1.85).round + 10
  end

  def level_percentage
    ( _experience.inspect.to_f / level_cap * 100 ).round
  end

  def level_cap
    ( (_level.inspect.to_i * 125) / 2 ).round
  end

  def level_up_boiii(remainder)
    self.model._level += 1
    self.model._health = 50
    self.model._experience = remainder.or(0)
    add_event_log('Good job kitty cat! You are now level ' + self.model._level.to_s + '!!!', 'success')
  end

  def death_from_above
    self.model._level = 1
    self.model._health = 50
    self.model._experience = 0
    self.model._mana = 0
    add_event_log('Back to level 1! ❨╯°□°❩╯︵┻━┻!!!!! ', 'danger')
  end

### event log
  def add_event_log(text = nil, status = 'default')
    _event_logs << {text: text.or(page._event_log_text), team_id: self.model.__id, user_id: Volt.user.__id, user_name: Volt.user._name, created_at: Time.now.to_i, alert_status: status}
    page._event_log_text = ''
    if _event_logs.size >= 11
      remove_event_log(_event_logs.first)
    end
  end

  def remove_event_log(log)
    _event_logs.delete(log)
  end

  def time_ago_in_words(t1, t2)
    s = t1.to_i - t2.to_i # distance between t1 and t2 in seconds

    resolution = if s > 29030400 # seconds in a year
      [(s/29030400).to_i, 'years']
    elsif s > 2419200
      [(s/2419200).to_i, 'months']
    elsif s > 604800
      [(s/604800).to_i, 'weeks']
    elsif s > 86400
      [(s/86400).to_i, 'days']
    elsif s > 3600 # seconds in an hour
      [(s/3600).to_i, 'hours']
    elsif s > 60
      [(s/60).to_i, 'minutes']
    else
      [s, 'seconds']
    end

    # singular v. plural resolution
    if resolution[0] == 1
      resolution.join(' ')[0...-1]
    else
      resolution.join(' ')
    end
  end
end
