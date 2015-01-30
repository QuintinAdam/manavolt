class TeamsController < Volt::ModelController
  model :store # allows us to use _teams instead of page._teams

  def index
  end

  def show
    _teams.find(_id: params._id).then do |results|
      self.model = results[0]
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

  #### Repeatable

  def add_repeatable
    _repeatables << {name: page._repeatable_name, team_id: self.model.__id}
    page._repeatable_name = ''
  end

  def remove_repeat(repeat)
    _repeatables.delete(repeat)
  end

  def did_positive_task(repeat)
    repeat.score = repeat.score.or(0)
    repeat.score += 1
  end

  def did_negative_task(repeat)
    repeat.score = repeat.score.or(0)
    repeat.score -= 1
  end
  #### Daily

  def add_daily
    _dailys << {name: page._daily_name, team_id: self.model.__id}
    page._daily_name = ''
  end

  def remove_daily(daily)
    _dailys.delete(daily)
  end

  def daliy_completed(daily)
    daily.completed = true
  end

  def daliy_uncompleted(daily)
    daily.completed = false
  end

  #### Todo

  def add_todo
    _todos << {name: page._todo_name, team_id: self.model.__id}
    page._todo_name = ''
  end

  def remove_todo(todo)
    _todos.delete(todo)
  end

  def todo_completed(todo)
    todo.completed = true
  end

  def todo_uncompleted(todo)
    todo.completed = false
  end


  #### Dashboard


  def add_mana
    self.model._mana += 5
  end

  def remove_mana
    self.model._mana -= 5
  end


  def get_health_percent
    (_health.inspect.to_i / 50) * 100
  end

  def add_health
    self.model._health += 5
  end

  def remove_health
    self.model._health -= 5
  end

  # def level_logic
  #   (_level.inspect.to_i)
  # end

  #### Temp Admin Panel

  def add_experience
    self.model._experience += 10
    if _experience >= level_cap
      level_up_boiii
    end
  end

  def remove_experience
    self.model._experience -= 10
  end

  def level_percentage
    ( _experience.inspect.to_f / level_cap * 100).round
  end

  def level_cap
    ( (_level.inspect.to_i * 125) / 2).round
  end

  def level_up_boiii
    self.model._level += 1
    self.model._health = 50
    self.model._experience = 0
  end

end
