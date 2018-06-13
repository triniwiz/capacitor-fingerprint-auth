import { Component } from '@angular/core';
import { NavController } from 'ionic-angular';
import { FingerPrintAuth } from 'capacitor-fingerprint-auth';
@Component({
  selector: 'page-home',
  templateUrl: 'home.html'
})
export class HomePage {
  auth: FingerPrintAuth;
  constructor(public navCtrl: NavController) {
    this.auth = new FingerPrintAuth();
  }

  async isAvailable() {
    await this.auth.available();
  }

  async verify() {
    try {
      await this.auth.verify();
    } catch (e) {
      console.log(e);
    }
  }
  async verifyWithFallback() {
    try {
      this.auth.verifyWithFallback();
    } catch (error) {
      console.log(error);
    }
  }
}
