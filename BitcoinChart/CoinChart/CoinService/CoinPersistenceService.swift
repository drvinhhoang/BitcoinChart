//
//  CoinPersistenceService.swift
//  BitcoinChart
//
//  Created by VinhHoang on 03/05/2023.
//

import Foundation
import CoreData
import SwiftUI

enum EntityName: String {
    case candleStick = "CandlestickEntity"
    case statistic24h = "Statistic24hEntity"
}

actor CoinPersistenceService {
    let container: NSPersistentContainer
    private let containerName: String = "CoinDataContainer"
    @Published var savedCandlesticks: [CandlestickEntity] = []
    @Published var savedStatistic24h: Statistic24hEntity? = nil
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { [weak self] _, error in
            guard let self else { return }
            if let error = error {
                BCLogger.log("Error loading core data! \(error)")
            }
            Task {
                await self.getStoredCandlesticks(range: .fourHour)
                self.savedStatistic24h = try? await self.getStoredData(entityName: .statistic24h).first
            }
        }
    }
    
    func getStoredCandlesticks(range: IntervalRange) {
        let request = NSFetchRequest<CandlestickEntity>(entityName: EntityName.candleStick.rawValue)
        request.predicate = NSPredicate(format: "intervalRange == %@", range.rawValue)
        do {
            savedCandlesticks = try container.viewContext.fetch(request)
        } catch let error {
            BCLogger.log("Error fetching Portfolio Entities: \(error)")
        }
    }
    
//    func getStatistic24h() {
//        guard let savedData: Statistic24hEntity = try? getStoredData(entityName: "Statistic24hEntity").first else { return }
//        self.savedStatistic24h = savedData
//    }
    
    func getStoredData<T: NSFetchRequestResult>(predicate: NSPredicate? = nil, entityName: EntityName) throws -> [T] {
        let request = NSFetchRequest<T>(entityName: entityName.rawValue)
        if let predicate {
            request.predicate = predicate
        }
        let savedData = try container.viewContext.fetch(request)
        return savedData
    }
    
    func add(candlesticks: [CandleStick], interval: IntervalRange) throws {
        getStoredCandlesticks(range: interval)
        if savedCandlesticks.isEmpty {
        } else {
            deleteAllEntities(savedCandlesticks)
        }
        for var candlestick in candlesticks {
            candlestick.toManagedObject(context: container.viewContext)
        }
        save()
        getStoredCandlesticks(range: interval)
    }
    
    func saveStatistic(_ statistic: Statistic24h?) throws {
        guard var statistic else { return }
        let savedObjects: [Statistic24hEntity] = try getStoredData(entityName: .statistic24h)
        if savedObjects.isEmpty {
            statistic.toManagedObject(context: container.viewContext)
        } else {
            guard let first = savedObjects.first else { return }
            first.high = statistic.high
            first.low = statistic.low
            first.baseVolume = statistic.baseVolume
            first.quoteVolume = statistic.quoteVolume
        }
        save()
        let savedData: [Statistic24hEntity] = try getStoredData(entityName: .statistic24h)
        self.savedStatistic24h = savedData.first
    }
    
    func deleteAllEntities(_ entities: [NSManagedObject]) {
        entities.forEach { entity in
            container.viewContext.delete(entity)
        }
    }
    
    private func save() {
        guard container.viewContext.hasChanges else { return }
        do {
            try container.viewContext.save()
        } catch let error {
            BCLogger.log("Error saving to CoreData. \(error)")
        }
    }
}
