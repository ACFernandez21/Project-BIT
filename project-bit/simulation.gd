extends RefCounted
## Prototype rules and fictional instruments. Orders lock their quoted price.

const ASSETS := ["Atlas Industries (stock)", "Pioneer Computing (stock)", "Union Manufacturing (stock)", "Residential home", "Commercial property"]
const BASE_PRICES := [10.0, 20.0, 15.0, 45000.0, 150000.0]
var elapsed := 0
var cash := 100.0
var holdings: Array[int] = [0, 0, 0, 0, 0]
var orders: Array[Dictionary] = []
var next_id := 1
var federal_heat := 0.0
# Reserved for the future sports betting system; financial trades never raise it.
var criminal_heat := 0.0


static func index_value(t: int, series: int, property_market: bool) -> float:
	var age := float(t + 60)
	if property_market:
		return 100.0 * exp(age * (0.004 if series == 0 else 0.003)) + (sin(age * 0.18 + series) - sin(float(series))) * 3.0
	return 100.0 * exp(age * [0.005, 0.007, 0.004][series]) + (sin(age * 0.64 + series) - sin(float(series))) * 7.0 + sin(age * 1.71) * 3.5


func price(asset: int) -> float:
	var series := asset - 3 if asset >= 3 else asset
	return snappedf(BASE_PRICES[asset] * index_value(elapsed, series, asset >= 3) / index_value(0, series, asset >= 3), 0.01)


func delay(asset: int) -> int:
	if asset < 3:
		return 1
	# Northern-hemisphere prototype: spring/summer closings are faster.
	var season_month := posmod(elapsed, 12)
	var months := 3 if season_month in [11, 0, 1] else (1 if season_month in [3, 4, 5, 6, 7] else 2)
	return months + (1 if asset == 4 else 0)


func reserved_cash() -> float:
	var total := 0.0
	for order in orders:
		if order.buy:
			total += order.total
	return total


func available_cash() -> float:
	return cash - reserved_cash()


func available_units(asset: int) -> int:
	var units := holdings[asset]
	for order in orders:
		if not order.buy and order.asset == asset:
			units -= order.quantity
	return units


func invested_value() -> float:
	var total := 0.0
	for asset in range(holdings.size()):
		total += holdings[asset] * price(asset)
	return total


func net_worth() -> float:
	return cash + invested_value()


func queue_order(asset: int, buy: bool, quantity: int) -> String:
	if asset < 0 or asset >= ASSETS.size() or quantity <= 0:
		return "Choose an asset and a positive whole quantity."
	var total := snappedf(price(asset) * quantity, 0.01)
	if buy and total > available_cash() + 0.001:
		return "Insufficient available cash. Pending buys already reserve their cost."
	if not buy and quantity > available_units(asset):
		return "Not enough unreserved holdings to sell."
	orders.append({"id": next_id, "asset": asset, "buy": buy, "quantity": quantity, "total": total, "due": elapsed + delay(asset)})
	next_id += 1
	return ""


func cancel_order(id: int) -> void:
	for i in range(orders.size()):
		if orders[i].id == id:
			orders.remove_at(i)
			return


func advance() -> Array[String]:
	elapsed += 1
	federal_heat = maxf(0.0, federal_heat - 1.0)
	var reports: Array[String] = []
	for i in range(orders.size() - 1, -1, -1):
		var order := orders[i]
		if order.due > elapsed:
			continue
		var direction := 1 if order.buy else -1
		holdings[order.asset] += direction * int(order.quantity)
		cash = snappedf(cash - direction * float(order.total), 0.01)
		federal_heat = minf(100.0, federal_heat + 0.5 + float(order.total) / 10000.0)
		reports.append("%s %d x %s for $%.2f." % ["Bought" if order.buy else "Sold", order.quantity, ASSETS[order.asset], order.total])
		orders.remove_at(i)
	return reports
