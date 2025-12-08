import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String}

  connect(){
    this.reload()
  }

  reload(){
    setInterval(function (){
      location.reload();
    }, 10000);
  }
}