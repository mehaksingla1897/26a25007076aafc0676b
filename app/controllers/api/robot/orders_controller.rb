class Api::Robot::OrdersController < ApplicationController
	before_action :find_robot
	before_action :command
	DIRECTION = ["NORTH","EAST","SOUTH","WEST"]

	def create
		simulate
		render json: {location: final_position}
	end
	# def simulation
	# 	@simulation ||= RobotSimulation.new(,command)
	# end

	def simulate
		if @commands.present?
			@commands.each do |command|
				case command
				when "PLACE"
					set_initial_position
				when "REPORT"
					store_position
				else
					process_command command
				end
			end
		end
		@robot.save
	end

	def final_position
		@position
	end
	

	def store_position
		@position << "#{@robot.x_position},#{@robot.y_position},#{@robot.facing}"
	end

	def process_command(command)
		case command
		when "LEFT"
			move_left
		when "RIGHT"
			move_right
		when "MOVE"
			move_forward
		end
	end

	def move_left
		index = DIRECTION.index @robot.facing
		pos = index == 0 ? 4 : index
		@robot.facing = DIRECTION[pos - 1]
	end

	def move_right
		index = DIRECTION.index @robot.facing
		pos  = index == 3 ? -1 : index
		@robot.facing = DIRECTION[pos + 1]
	end

	def move_forward
		case @robot.facing
		when "NORTH"
			@robot.y_position = @robot.y_position + 1 if @robot.y_position < 4
		when "SOUTH"
			@robot.y_position = @robot.y_position - 1 if @robot.y_position > 0
		when "EAST"
			@robot.x_position = @robot.x_position + 1 if @robot.x_position < 4
		when "WEST"
			@robot.x_position = @robot.x_position - 1 if @robot.x_position > 0
		end
	end
	def set_initial_position
		cmd = @commands[1].split(",")
		@robot.x_position = cmd[0].to_i
		@robot.y_position = cmd[1].to_i
		@robot.facing = cmd[2]
	end

	def command
		@position = []
		cmd = params[:commands]
		cmd = cmd.split()
		i = -1
		cmd.each_with_index do |c,index|
			if c == "PLACE" && index != cmd.length - 1
				placement = cmd[index + 1]
				placement = placement.split(",")
				if placement.count == 3
					binding.pry
					if placement[0].match("^[0-9]*$").present? && placement[0].to_i < 5 && placement[1].match("^[0-9]*$").present? && placement[1].to_i < 5 && DIRECTION.include?(placement[2])
						i = index
						break 
					end 
				end
			end
		end
		@commands = []
		while(i > -1 && i< cmd.length)
			@commands << cmd[i]
			i = i+1
		end
	end
	def find_robot
		@robot ||= ::Robot.where(id: params[:id]).first_or_create
	end
end
