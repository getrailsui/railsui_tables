// app/javascript/controllers/railsui_table_controller.js
import { Controller } from "@hotwired/stimulus";
var railsui_table_controller_default = class extends Controller {
  static targets = ["table", "row"];
};

// app/javascript/controllers/railsui_table_filter_controller.js
import { Controller as Controller2 } from "@hotwired/stimulus";
var railsui_table_filter_controller_default = class extends Controller2 {
  static values = { delay: { type: Number, default: 250 } };
  connect() {
    this.submit = this.submit.bind(this);
  }
  queueSubmit() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(this.submit, this.delayValue);
  }
  submit() {
    this.element.requestSubmit();
  }
  disconnect() {
    clearTimeout(this.timeout);
  }
};

// app/javascript/railsui_tables/index.js
function registerRailsuiTables(application) {
  application.register("railsui-table", railsui_table_controller_default);
  application.register("railsui-table-filter", railsui_table_filter_controller_default);
}
export {
  railsui_table_controller_default as RailsuiTableController,
  railsui_table_filter_controller_default as RailsuiTableFilterController,
  registerRailsuiTables
};
