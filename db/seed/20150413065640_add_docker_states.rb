class AddDockerStates < ActiveRecord::SeedMigration
    DOCKER_STATES ={
        1 => ['RUNNING','run'],
        2 => ['PAUSED','pause'],
        3 => ['SUSPENDED','suspend'],
        4 => ['STOPPED','stop'],
        5 => ['KILLED','kill']
    }
  
  def self.up
    DOCKER_STATES.each do |index,state|
        new_state = DockerCvmState.new
        new_state.state = state[0]
        new_state.command = state[1]
        new_state.save
    end
  end
  
end
