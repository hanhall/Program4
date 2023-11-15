from typing import List

class Action:
    def execute(self):
        pass  # Action logic to be implemented in subclasses

class State:
    def getActions(self) -> List['Action']:
        pass  # Action(s) while in state

    def getEntryActions(self) -> List['Action']:
        pass  # Action(s) when entering state

    def getExitActions(self) -> List['Action']:
        pass  # Action(s) when exiting state

    def getTransitions(self) -> List['Transition']:
        pass  # State’s outgoing transitions

class Transition:
    def isTriggered(self) -> bool:
        pass  # True if transition condition is true

    def getToState(self) -> 'State':
        pass  # State to transition into

    def getActions(self) -> List['Action']:
        pass  # Action(s) to execute when transitioning

class StateMachine:
    def __init__(self, initial_state: 'State'):
        self.initialState = initial_state  # State the state machine starts in
        self.currentState = initial_state  # State machine’s current state

    def update(self) -> List['Action']:
        actions = []  # List of actions to be returned

        triggered = None  # Assume no transitions triggered

        # Check transitions
        for transition in self.currentState.getTransitions():
            if transition.isTriggered():  # Check whether transition is triggered
                triggered = transition  # Save the triggered transition
                break  # Stop checking transitions

        if triggered:  # Was a transition triggered?
            toState = triggered.getToState()

            # Create a list of actions to execute for the transition
            actions += self.currentState.getExitActions()
            actions += triggered.getActions()
            actions += toState.getEntryActions()
            self.currentState = toState  # Update the current state
            return actions
        else:
            return self.currentState.getActions()
