#Program 4 for CS 330
#Hannah Hall and Joshua Velazquez

import numpy as np
from datetime import datetime

# Setup and Configuration
#np.random.seed(42)  # Set seed for reproducibility
scenario = 1

# Execute Iterations and Transitions
def run_scenario(scenario):

    # Apply different conditions depending on scenario
    scenario_trace = [True, False][scenario - 1]
    scenario_iterations = [100, 1000000][scenario - 1]
    scenario_interval = [1, 10000][scenario - 1]
    transition_probability = [[0.8, 0.4, 0.3, 0.4, 0.3, 0.3, 0.8, 0.8, 0.8],
                            [0.9, 0.6, 0.3, 0.2, 0.2, 0.4, 0.7, 0.9, 0.7]][scenario - 1]
     # Support Functions to organize and format the output data
    def write_text(textfile, msg, first=False):
        with open(textfile, 'a') as file:
            file.write(msg + '\n' if not first else msg)

    def num_width(x, left, right):
        return format(round(x, right), f'.{right}f').rjust(left + right + (1 if right > 0 else 0))

    # Initialization
    output_path = "./"
    output_file = f"{output_path}Scenario {scenario}.txt"

    write_text(output_file, f"CS 330, State machines, Begin {str(datetime.now())}", True)

    # Constants for States
    FOLLOW = 1
    PULL_OUT = 2
    ACCELERATE = 3
    PULL_IN_AHEAD = 4
    PULL_IN_BEHIND = 5
    DECELERATE = 6
    DONE = 7

    # Program State and Counters
    state_count = [0] * 7
    transition_count = [0] * 9

    # State Action Functions
    def follow_action():
        if scenario_trace:
            write_text(output_file, "state= 1 Follow")
        state_count[FOLLOW - 1] += 1

    def pull_out_action():
        if scenario_trace:
            write_text(output_file, "state= 2 Pull out")
        state_count[PULL_OUT - 1] += 1

    def accelerate_action():
        if scenario_trace:
            write_text(output_file, "state= 3 Accelerate")
        state_count[ACCELERATE - 1] += 1

    def pull_in_ahead_action():
        if scenario_trace:
            write_text(output_file, "state= 4 Pull in ahead")
        state_count[PULL_IN_AHEAD - 1] += 1

    def pull_in_behind_action():
        if scenario_trace:
            write_text(output_file, "state= 5 Pull in behind")
        state_count[PULL_IN_BEHIND - 1] += 1

    def decelerate_action():
        if scenario_trace:
            write_text(output_file, "state= 6 Decelerate")
        state_count[DECELERATE - 1] += 1

    def done_action():
        if scenario_trace:
            write_text(output_file, "state= 7 Done")
        state_count[DONE - 1] += 1

    def get_transition_function(state):
        transition_functions = {
            FOLLOW: follow_action,
            PULL_OUT: pull_out_action,
            ACCELERATE: accelerate_action,
            PULL_IN_AHEAD: pull_in_ahead_action,
            PULL_IN_BEHIND: pull_in_behind_action,
            DECELERATE: decelerate_action,
            DONE: done_action
        }
        return transition_functions[state]

    for i in range(1, scenario_iterations + 1):
        if scenario_trace:
            write_text(output_file, f"\niteration= {i}")

        state = FOLLOW
        follow_action()

        while state != DONE:
            # Get random number between 0 and 1
            R = np.random.uniform(0.0, 1.0)

            # Check Transitions
            if state == FOLLOW:
                if R < transition_probability[0]:
                    transition_count[0] += 1
                    state = PULL_OUT
                else:
                    state = FOLLOW

            elif state == PULL_OUT:
                if R < transition_probability[1]:
                    transition_count[1] += 1
                    state = ACCELERATE
                elif R < (transition_probability[1]+transition_probability[3]):
                    transition_count[3] += 1
                    state = PULL_IN_BEHIND
                else:
                    state = PULL_OUT

            elif state == ACCELERATE:
                if R < transition_probability[2]:
                    transition_count[2] += 1
                    state = PULL_IN_AHEAD
                elif R < (transition_probability[2]+transition_probability[4]):
                    transition_count[4] += 1
                    state = PULL_IN_BEHIND
                elif R < (transition_probability[1]+transition_probability[3]+transition_probability[5]):
                    transition_count[5] += 1
                    state = DECELERATE
                else:
                    state = ACCELERATE

            elif state == PULL_IN_AHEAD:
                if R < transition_probability[8]:
                    transition_count[8] += 1
                    state = DONE
                else:
                    state = PULL_IN_AHEAD

            elif state == PULL_IN_BEHIND:
                if R < transition_probability[6]:
                    transition_count[6] += 1
                    state = FOLLOW
                else:
                    state = PULL_IN_BEHIND

            elif state == DECELERATE:
                if R < transition_probability[7]:
                    transition_count[7] += 1
                    state = PULL_IN_BEHIND
                else:
                    state = DECELERATE

            # Call action after determining next state
            get_transition_function(state)()

        # Terminal feedback for program execution
        if i % scenario_interval == 0:
            print('.', end='')

    print()

    # Report Scenario Parameters and Execution Statistics
    state_frequency = np.array(state_count) / sum(state_count)
    transition_frequency = np.array(transition_count) / sum(transition_count)
    

    write_text(output_file, f"\nscenario                = {scenario}")
    write_text(output_file, f"trace                   = {scenario_trace}")
    write_text(output_file, f"iterations              = {scenario_iterations}")
    write_text(output_file, f"transition probabilities= {' '.join(map(str, transition_probability))}")
    write_text(output_file, f"state counts            = {' '.join(map(str, state_count))}")
    write_text(output_file, f"state frequencies       = {' '.join(map(lambda x: num_width(x, 1, 3), state_frequency))}")
    write_text(output_file, f"transition counts       = {' '.join(map(str, transition_count))}")
    write_text(output_file, f"transition frequencies  = {' '.join(map(lambda x: num_width(x, 1, 3), transition_frequency))}")

    # Verify Counts
    error = None

    if state_count[0] < transition_count[6]:
        error = 1
    if state_count[1] < transition_count[0]:
        error = 2
    if state_count[2] < transition_count[1]:
        error = 3
    if state_count[3] < transition_count[2]:
        error = 4
    if state_count[4] < sum(transition_count[3:6]):
        error = 5
    if state_count[5] < transition_count[5]:
        error = 6
    if state_count[6] < transition_count[8]:
        error = 7
    if state_count[0] < scenario_iterations:
        error = 8
    if state_count[6] != scenario_iterations:
        error = 9
    if transition_count[8] != scenario_iterations:
        error = 10

    if error is None:
        print("Verification OK")
    else:
        print(f"Verification not OK, error= {error}")

    # Report Program End
    write_text(output_file, f"\nCS 330, State machines, End")

# Run Scenario 1, increment scenario, and then run Scenario 2
run_scenario(scenario)
scenario += 1
run_scenario(scenario)
