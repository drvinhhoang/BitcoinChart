//
//  CoinPersistenceService.swift
//  BitcoinChart
//
//  Created by VinhHoang on 03/05/2023.
//

import Foundation
import CoreData
import Combine

enum EntityName: String {
    case candleStick = "CandlestickEntity"
    case statistic24h = "Statistic24hEntity"
    case currentPrice = "CurrentPriceEntity"
}

class CoinPersistenceService: CoinPersistence {
    let container: NSPersistentContainer
    private let containerName: String = "CoinDataContainer"
    var savedCandlesticks = PassthroughSubject<[CandlestickEntity], Never>()
    var savedStatistic24h = PassthroughSubject<Statistic24hEntity?, Never>()
    var currentPrice = PassthroughSubject<String, Never>()
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { [weak self] _, error in
            guard let self else { return }
            if let error = error {
                BCLogger.log("Error loading core data! \(error)")
            }
            self.updateDisplayData()
        }
    }
    
    func updateDisplayData(range: IntervalRange = .fourHour) {
        let candlesticks = self.getStoredCandlesticks(range: range)
        let savedStatistic: Statistic24hEntity? = try? getStoredData(entityName: .statistic24h, context: container.viewContext).first
        let savedPrice: CurrentPriceEntity? = try? getStoredData(entityName: .currentPrice, context: container.viewContext).first
        savedCandlesticks.send(candlesticks)
        savedStatistic24h.send(savedStatistic)
        if let price = savedPrice?.currentPrice, !price.isEmpty {
            currentPrice.send(price)
        }
    }
    
    func getStoredCandlesticks(range: IntervalRange) -> [CandlestickEntity] {
        let request = NSFetchRequest<CandlestickEntity>(entityName: EntityName.candleStick.rawValue)
        request.predicate = NSPredicate(format: "intervalRange == %@", range.rawValue)
        
        do {
            let savedCandlesticks = try container.viewContext.fetch(request)
            return savedCandlesticks
        } catch let error {
            BCLogger.log("Error fetching Portfolio Entities: \(error)")
            return []
        }
    }
    
    func getStoredData<T: NSFetchRequestResult>(predicate: NSPredicate? = nil, entityName: EntityName, context: NSManagedObjectContext) throws -> [T] {
        let request = NSFetchRequest<T>(entityName: entityName.rawValue)
        if let predicate {
            request.predicate = predicate
        }
        let savedData = try context.fetch(request)
        return savedData
    }
    
    func save(candlesticks: [CandleStick], interval: IntervalRange) async throws {
        guard !candlesticks.isEmpty else { return }
        let savedEntities = getStoredCandlesticks(range: interval)
        try await container.performBackgroundTask { context in
            if !savedEntities.isEmpty {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.candleStick.rawValue)
                request.predicate = NSPredicate(format: "intervalRange == %@", interval.rawValue)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                try context.execute(deleteRequest)
            }
            for var candlestick in candlesticks {
                candlestick.toManagedObject(context: context)
            }
            self.save(context: context)
            let candlesticks = self.getStoredCandlesticks(range: interval)
            self.savedCandlesticks.send(candlesticks)
        }
    }
    
    func saveStatistic(_ statistic: Statistic24h?) async throws {
        guard var statistic else { return }
        try await container.performBackgroundTask { [weak self] context in
            guard let self else { return }
            let savedObjects: [Statistic24hEntity] = try self.getStoredData(entityName: .statistic24h, context: context)
            if savedObjects.isEmpty {
                statistic.toManagedObject(context: context)
            } else {
                guard let first = savedObjects.first else { return }
                first.high = statistic.high
                first.low = statistic.low
                first.baseVolume = statistic.baseVolume
                first.quoteVolume = statistic.quoteVolume
            }
            self.save(context: context)
            let savedData: [Statistic24hEntity] = try self.getStoredData(entityName: .statistic24h, context: context)
            self.savedStatistic24h.send(savedData.first)
        }
    }
    
    func saveCurrentPrice(_ price: CurrentPrice?) async throws {
        guard var price, !price.price.isEmpty else { return }
        try await container.performBackgroundTask { [weak self] context in
            guard let self else { return }
            let savedObjects: [CurrentPriceEntity] = try self.getStoredData(entityName: .currentPrice, context: context)
            if savedObjects.isEmpty {
                price.toManagedObject(context: context)
            } else {
                guard let firstObjest = savedObjects.first else { return }
                firstObjest.currentPrice = price.price
            }
            self.save(context: context)
            let savedData: [CurrentPriceEntity] = try self.getStoredData(entityName: .currentPrice, context: context)
            guard let price = savedData.first?.currentPrice else { return }
            self.currentPrice.send(price)
        }
    }
    
    func save(context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error {
            BCLogger.log("Error saving to CoreData. \(error)")
        }
    }
}
