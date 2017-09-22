import Foundation
import UIKit

extension UIView {
    func addFillingSubview(_ subview: UIView) {
        self.addSubview(subview)
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        subview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
}

struct ScheduleScreen {
    
    private let dataSource: UITableViewDataSource!
    var timeSlots: [TimeSlot]
    
    init(schedule: Schedule) {
        dataSource = ScheduleDataSource(schedule)
        timeSlots = ScheduleDataSource(schedule).getTimeSlots()
    }
    
    func makeViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.title = "Schedule"
        let scheduleTable = ScheduleTableView()
        
        scheduleTable.strongDataSource = dataSource
        scheduleTable.rowHeight = UITableViewAutomaticDimension
        scheduleTable.estimatedRowHeight = 50
        
        
        let delegate = ScheduleDelegate(timeSlots)
        delegate.viewController = viewController
        scheduleTable.strongDelegate = delegate
        viewController.view.addFillingSubview(scheduleTable)

        
        return viewController
    }
}

class ScheduleTableView: UITableView {
    fileprivate var strongDataSource: UITableViewDataSource? {
        didSet {
            dataSource = strongDataSource
        }
    }
    fileprivate var strongDelegate: UITableViewDelegate? {
        didSet {
            delegate = strongDelegate
        }
    }
}

struct TimeSlot {
    let date: Date
    let events: [Event]
}

class ScheduleDelegate: NSObject, UITableViewDelegate {
    weak var viewController: UIViewController?
    var timeSlots: [TimeSlot]
    
    init(_ timeSlots: [TimeSlot]){
        self.timeSlots = timeSlots
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        
        let id = timeSlots[indexPath.section].events[indexPath.row].id
        print(id)
        let eventScreen = EventScreen(id).getController();
        
        eventScreen.view.backgroundColor = .white
        if #available(iOS 11.0, *) {
            eventScreen.navigationItem.largeTitleDisplayMode = .never
        }
        viewController?.navigationController?.pushViewController(eventScreen, animated: true)
    }
    
}

class EventScreen {
    
    var eventId = 0
    
    init(_ id: Int) {
        self.eventId = id
    }
    
    func setupLabelConstraints(_ label: UILabel, _ eventScreen: UIViewController){
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(greaterThanOrEqualTo: eventScreen.view.centerXAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: eventScreen.view.widthAnchor, constant: -20).isActive = true
        label.numberOfLines = 0
    }
    
    func setDefaultStackView(_ stackView: UIStackView) {
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func constrainStackView(StackView stackView: UIStackView, ViewController eventScreen: UIViewController) {
        let container = eventScreen.view!
        
        if #available(iOS 11.0, *) {
            container.addSubview(stackView)
            stackView.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor).isActive = true
            stackView.leftAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leftAnchor).isActive = true
            stackView.rightAnchor.constraint(equalTo: container.safeAreaLayoutGuide.rightAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    func getController( ) -> UIViewController {
        
        let eventScreen = UIViewController()
        eventScreen.title = "Event"
        
        let headerLabel = UILabel()
        let infoLabel = UILabel()
        
        let labels: [UILabel] = [headerLabel, infoLabel]
        labels.forEach { (label) in
            label.numberOfLines = 0
        }
        
        let stackView = UIStackView(arrangedSubviews: labels)
        setDefaultStackView(stackView)
        constrainStackView(StackView: stackView, ViewController: eventScreen)
        
        headerLabel.font = UIFont(name: "AAZuehlkeMedium", size: 18)
              
        guard let event = JsonReader.getJson(FileName: "eventDetails.json", type: DetailsList.self).details.first(where: { $0.id == eventId }) else {
            return UIViewController()
        }
        
        headerLabel.text = event.header
        infoLabel.text = event.info
        
        return eventScreen
    }
}

class ScheduleDataSource: NSObject, UITableViewDataSource {
    
    let timeSlots: [TimeSlot]
    
    func getTimeSlots() -> [TimeSlot]{
        return timeSlots
    }
    
    init(_ schedule: Schedule) {
        self.timeSlots = schedule.asOrderedTimeSlots()
    }
    
    @available(iOS 2.0, *)
    public func numberOfSections(in tableView: UITableView) -> Int {
        return timeSlots.count
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeSlots[section].events.count
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return timeSlots[section].sectionTitle
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = self.timeSlots[indexPath.section].events[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = "\(event.startTime) - \(event.endTime) - \(event.location)"

        return cell
    }
}

//TODO: time zone?
fileprivate let dayAndTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, HH:mm"
    return formatter
}()


fileprivate let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
}()

fileprivate extension Event {
    var startTime: String {
        return timeFormatter.string(from: date)
    }
    
    var endTime: String {
        let endDate = Calendar.current.date(byAdding: .minute, value: durationInMinutes, to: date)!
        return timeFormatter.string(from: endDate)
    }
}

fileprivate extension Schedule {
    
    func asOrderedTimeSlots() -> [TimeSlot] {
        return self.events.group(by: { $0.date }).map { date, events in
            return TimeSlot(date: date, events: events)
            }.sorted(by: { timeSlot, otherTimeSlot in
                return timeSlot.date.compare(otherTimeSlot.date) == ComparisonResult.orderedAscending
            })
    }
}

fileprivate extension TimeSlot {
    var sectionTitle: String {
        return dayAndTimeFormatter.string(from: date)
    }
}

