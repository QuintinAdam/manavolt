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
    _teams << { name: page._new_team }
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




  #### Daily

  def add_daily
    _dailys << {name: page._daily_name, team_id: self.model.__id}
    page._daily_name = ''
  end

  def remove_daily(daily)
    _dailys.delete(daily)
  end




  #### Todo

  def add_todo
    _todos << {name: page._todo_name, team_id: self.model.__id}
    page._todo_name = ''
  end

  def remove_todo(todo)
    _todos.delete(todo)
  end

end
