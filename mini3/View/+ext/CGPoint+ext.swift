import Foundation

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt((self.x - point.x) * (self.x - point.x) + (self.y - point.y) * (self.y - point.y))
    }
}
