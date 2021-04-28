// Represents the state of a Penball game.
public enum PenballState {
    // The level has not been started yet.
    case notStarted
    
    // The level has been started.
    case started
    
    // The level has been failed (i.e. one of the balls left the screen or hit a hazard.)
    case failed
    
    // The level has been completed (i.e. all of the balls have reached their finish points.)
    case completed
    
    // The level is currently transitioning to another level.≥
    case transitioning
}
