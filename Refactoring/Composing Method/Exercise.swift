//
//  Exercise.swift
//  Refactoring
//
//  Created by Kai Lee on 1/6/25.
//

import Foundation

// MARK: - 1
class Exercise {
    struct Order {
        let id: String
        let items: [Item]
    }
    
    struct Item {
        let name: String
        let price: Double
        let quantity: Int
        let weight: Double
    }
    
    func processOrders(orders: [Order], discount: Double) -> [String] {
        var results: [String] = []
        for order in orders {
            var total = 0.0
            for item in order.items {
                total += item.price * Double(item.quantity)
            }
            if total > 100 {
                total -= total * discount
            }
            let result = "\(order.id): \(total)"
            results.append(result)
        }
        return results
    }
    
    // MARK: Refactored
    func re_processOrders(orders: [Order], discount: Double) -> [String] {
        orders.map { order in
            let totalPrice = calculateTotalPrice(for: order.items)
            let discountedTotalPrice = applyDiscountIfNeeded(to: totalPrice, discount: discount)
            return "\(order.id): \(discountedTotalPrice)"
        }
    }
    
    private func calculateTotalPrice(for items: [Item]) -> Double {
        items.reduce(0) { $0 + $1.price * Double($1.quantity) }
    }
    
    private func applyDiscountIfNeeded(to price: Double, discount: Double) -> Double {
        price > 100 ? price - price * discount : price
    }
}

// MARK: - 2
extension Exercise {
    func calculateShippingCosts(orders: [Order]) -> Double {
        var totalShippingCost = 0.0
        var heavyItemCount = 0
        for order in orders {
            for item in order.items {
                if item.weight > 20 {
                    heavyItemCount += 1
                }
                totalShippingCost += item.weight * 0.05
            }
        }
        if heavyItemCount > 5 {
            totalShippingCost -= 10.0
        }
        if totalShippingCost < 0 {
            totalShippingCost = 0
        }
        return totalShippingCost
    }
    
    // MARK: Refactored
    func re_calculateShippingCosts(orders: [Order]) -> Double {
        let totalShippingCost = calculateTotalShippingCost(in: orders)
        let heavyItemCount = countHeavyItems(in: orders)
        let adjustedShippingCost = adjustShippingCostIfNeeded(totalShippingCost, heavyItemCount: heavyItemCount)
        return max(adjustedShippingCost, 0)
    }
    
    private func calculateTotalShippingCost(in orders: [Order]) -> Double {
        orders.flatMap(\.items)
            .reduce(0) { $0 + $1.weight * 0.05 }
    }
    
    private func countHeavyItems(in orders: [Order]) -> Int {
        orders.flatMap(\.items).filter { $0.weight > 20 }.count
    }
    
    private func adjustShippingCostIfNeeded(_ cost: Double, heavyItemCount: Int) -> Double {
        heavyItemCount > 5 ? cost - 10.0 : cost
    }
}

// MARK: - 3
extension Exercise {
    struct Sale {
        let sellerID: String
        let amount: Double
    }
    
    func calculateCommission(sales: [Sale], baseRate: Double, bonusRate: Double) -> [String: Double] {
        var commissions: [String: Double] = [:]
        for sale in sales {
            var rate = baseRate
            if sale.amount > 1000 {
                rate += bonusRate
            }
            let commissionValue = sale.amount * rate
            if let existingValue = commissions[sale.sellerID] {
                commissions[sale.sellerID] = existingValue + commissionValue
            } else {
                commissions[sale.sellerID] = commissionValue
            }
        }
        return commissions
    }
    
    // MARK: Refactored
    func re_calculateCommission(sales: [Sale], baseRate: Double, bonusRate: Double) -> [String: Double] {
        var commissions: [String: Double] = [:]
        for sale in sales {
            var rate = determineRate(for: sale, baseRate: baseRate, bonusRate: bonusRate)
            let commissionValue = sale.amount * rate
            commissions[sale.sellerID, default: 0] += commissionValue
        }
        return commissions
    }
    
    private func determineRate(for sale: Sale, baseRate: Double, bonusRate: Double) -> Double {
        sale.amount > 1000 ? baseRate + bonusRate : baseRate
    }
}
