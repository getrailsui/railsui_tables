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

// app/javascript/controllers/railsui_table_expandable_controller.js
import { Controller as Controller3 } from "@hotwired/stimulus";
var railsui_table_expandable_controller_default = class extends Controller3 {
  toggle(event) {
    const button = event.currentTarget;
    const detail = document.getElementById(button.dataset.detailId);
    if (!detail) return;
    event.preventDefault();
    const expanded = button.getAttribute("aria-expanded") === "true";
    button.setAttribute("aria-expanded", String(!expanded));
    detail.hidden = expanded;
    if (!expanded) {
      const frame = detail.querySelector("turbo-frame[data-src]");
      if (frame && !frame.getAttribute("src")) frame.setAttribute("src", frame.dataset.src);
    }
  }
};

// app/javascript/railsui_tables/index.js
function registerRailsuiTables(application) {
  application.register("railsui-table", railsui_table_controller_default);
  application.register("railsui-table-filter", railsui_table_filter_controller_default);
  application.register("railsui-table-expandable", railsui_table_expandable_controller_default);
}
export {
  railsui_table_controller_default as RailsuiTableController,
  railsui_table_expandable_controller_default as RailsuiTableExpandableController,
  railsui_table_filter_controller_default as RailsuiTableFilterController,
  registerRailsuiTables
};
