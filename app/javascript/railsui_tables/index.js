import RailsuiTableController from "../controllers/railsui_table_controller"
import RailsuiTableFilterController from "../controllers/railsui_table_filter_controller"
import RailsuiTableExpandableController from "../controllers/railsui_table_expandable_controller"

export function registerRailsuiTables(application) {
  application.register("railsui-table", RailsuiTableController)
  application.register("railsui-table-filter", RailsuiTableFilterController)
  application.register("railsui-table-expandable", RailsuiTableExpandableController)
}

export { RailsuiTableController, RailsuiTableFilterController, RailsuiTableExpandableController }
