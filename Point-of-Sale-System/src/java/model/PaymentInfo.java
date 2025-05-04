/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author dulan
 */

import java.io.Serializable;

public class PaymentInfo implements Serializable {
    private String paymentMethod;
    private double amountTendered;
    private String cardLast4Digits;

    // Getters and Setters
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public double getAmountTendered() { return amountTendered; }
    public void setAmountTendered(double amountTendered) { this.amountTendered = amountTendered; }
    public String getCardLast4Digits() { return cardLast4Digits; }
    public void setCardLast4Digits(String cardLast4Digits) { this.cardLast4Digits = cardLast4Digits; }
}
