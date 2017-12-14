import Foundation
import UIKit
import RxSwift

struct ScheduleScreen: Screen {
    
    var schedule: ScheduleModel
    
    func makeViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.title = "Schedule"
        let scheduleTable = ScheduleTableView()
        
        let dataSource = ScheduleDataSource(schedule, { event in
            let content = event.details.map { loadableDetails -> Screen in
                switch loadableDetails {
                case .loading:
                    return AppLoadingScreen()
                case .loaded(let details):
                    return EventScreen(details: details)
                }
            }
            let screen = ContainerScreen(content: content).makeViewController()
            viewController.navigationController?.pushViewController(screen, animated: true)
        })
        
        scheduleTable.strongDataSource = dataSource
        scheduleTable.rowHeight = UITableViewAutomaticDimension
        scheduleTable.estimatedRowHeight = 50
        
        let footer = UIView()
        let label = UILabel()
        label.text = "ZeCamp commit \(Bundle.main.shortCommitId!).\n© 2017 Zuhlke Engineering Ltd. ✨"
        label.numberOfLines = 0
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        footer.addSubview(label)
        
        scheduleTable.tableFooterView = footer
        footer.layoutMargins = UIEdgeInsets(top: 15, left: 8, bottom: 8, right: 8)
        
        [
            label.topAnchor.constraint(equalTo: footer.layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: footer.layoutMarginsGuide.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: footer.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: footer.layoutMarginsGuide.trailingAnchor),
            ].activateAll()
        
        footer.layoutIfNeeded()
        footer.frame.size = footer.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
        
        scheduleTable.strongDelegate = dataSource
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
    let events: [EventModel]
}

class EventScreen : Screen {
    
    var details: EventDetails?
    
    init(details: EventDetails?) {
        self.details = details
    }
    
    func setupLabelConstraints(_ label: UILabel, _ eventScreen: UIViewController){
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(greaterThanOrEqualTo: eventScreen.view.centerXAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: eventScreen.view.widthAnchor, constant: -20).isActive = true
        label.numberOfLines = 0
    }
    
    func getDefaultStackView(_ labels: [UILabel]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    func constrainStackView(StackView stackView: UIStackView, ViewController eventScreen: UIViewController) {
        let container = eventScreen.view!
        
        container.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: container.safeAreaLayoutGuide.trailingAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: container.safeAreaLayoutGuide.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: container.safeAreaLayoutGuide.rightAnchor).isActive = true
    }
    
    func makeViewController( ) -> UIViewController {
        
        let eventScreen = UIViewController()
        eventScreen.title = "Event"
        
        let headerLabel = UILabel()
        let infoLabel = UILabel()
        
        let labels: [UILabel] = [headerLabel, infoLabel]
        labels.forEach { (label) in
            label.numberOfLines = 0
        }
        
        let stackView = getDefaultStackView(labels)
        constrainStackView(StackView: stackView, ViewController: eventScreen)
        
        headerLabel.font = UIFont(name: "AAZuehlkeMedium", size: 18)
        
        guard let details = details else {
            return UIViewController()
        }
        
        headerLabel.text = details.header
        infoLabel.text = details.info
        
        eventScreen.view.backgroundColor = .white
        eventScreen.navigationItem.largeTitleDisplayMode = .never
        return eventScreen
    }
}

class ScheduleDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    let timeSlots: [TimeSlot]
    var navigate: (EventModel) -> Void
    
    init(_ schedule: ScheduleModel, _ navigate: @escaping (EventModel) -> Void) {
        self.timeSlots = schedule.asOrderedTimeSlots()
        self.navigate = navigate
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        navigate(timeSlots[indexPath.section].events[indexPath.row])
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
        let event = self.timeSlots[indexPath.section].events[indexPath.row].summary
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

fileprivate extension EventSummary {
    var startTime: String {
        return timeFormatter.string(from: date)
    }
    
    var endTime: String {
        let endDate = Calendar.current.date(byAdding: .minute, value: durationInMinutes, to: date)!
        return timeFormatter.string(from: endDate)
    }
}

fileprivate extension ScheduleModel {
    
    func asOrderedTimeSlots() -> [TimeSlot] {
        return self.events.group(by: { $0.summary.date }).map { date, events in
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

