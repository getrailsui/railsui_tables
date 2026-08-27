import RailsuiTableController from "../controllers/railsui_table_controller"
import RailsuiTableFilterController from "../controllers/railsui_table_filter_controller"

export function registerRailsuiTables(application) {
  application.register("railsui-table", RailsuiTableController)
  application.register("railsui-table-filter", RailsuiTableFilterController)
}

export { RailsuiTableController, RailsuiTableFilterController }
