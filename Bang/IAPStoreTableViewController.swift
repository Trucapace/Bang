//
//  IAPStoreTableViewController.swift
//  Bang
//
//  Created by David Blanck on 2/4/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit

class IAPStoreTableViewController: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    @IBOutlet weak var exitButton: UIBarButtonItem!
    @IBOutlet weak var restoreButton: UIBarButtonItem!
        
    //In-App Purchases
    let productIdentifiers = Set(["com.pointblanckconsulting.Bang.adRemover", "com.pointblanckconsulting.Bang.packageA", "com.pointblanckconsulting.Bang.packageB", "com.pointblanckconsulting.Bang.packageC", "com.pointblanckconsulting.Bang.packageD", "com.pointblanckconsulting.Bang.packageE"])
    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        self.navigationItem.title = "!Bang Store"
    
        
        
        //register your class with the delegate and add the transaction observer
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        print("view loaded")
        requestProductData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func restoreButtonPressed(sender: UIBarButtonItem) {
        exitButton.enabled = false
        restoreButton.enabled = false
        restorePurchases()
        
    }
    
    @IBAction func exitButtonPressed(sender: UIBarButtonItem) {
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ProductTableViewCell = tableView.dequeueReusableCellWithIdentifier("ProductCell", forIndexPath: indexPath) as! ProductTableViewCell

        // Configure the cell...
        
        cell.titleLabel.text = productsArray[indexPath.row].localizedTitle
        cell.detailLabel?.text = productsArray[indexPath.row].localizedDescription
        cell.priceButton.setTitle(String(productsArray[indexPath.row].price), forState: UIControlState.Normal)
        
        cell.priceButton.layer.cornerRadius = 10
        cell.priceButton.layer.backgroundColor = kPurpleColor.CGColor
        cell.priceButton.tintColor = UIColor.whiteColor()
        
        cell.delegate = self
        
        cell.indexPath = indexPath

        return cell
    }

    //In-App Purchase helper functions
    
    
    func addRebangs(quantityToAdd: Int) {
        let currentReBangs = PFUser.currentUser()!["reBangs"] as! Int
        print("Current user rebangs: \(currentReBangs)")
        PFUser.currentUser()!["reBangs"] = currentReBangs + quantityToAdd
        PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if success {
                print("Quantity to add: \(quantityToAdd)")
                print("User saved with \(PFUser.currentUser()!["reBangs"]) reBangs")
                
                let newReBangsAlert: UIAlertController = UIAlertController(title: "More ReBangs!", message: "You have received more \(quantityToAdd) ReBangs.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                
                newReBangsAlert.addAction(okAlertAction)
                self.presentViewController(newReBangsAlert, animated: true, completion: nil)
                
            } else {
                print("error saving user")
                self.showErrorView(error!)
            }
        })
    }
    
    func removeAds() {
        PFUser.currentUser()!["isAdFree"] = true
        PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if success {
                let alert = UIAlertController(title: "Ad Free Experience!", message: "Congratulations!  Your !Bang experience is now Ad free.  Thank you for your support.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                alert.addAction(okAlertAction)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                print("error saving user")
                self.showErrorView(error!)
            }

        })
        


    }
    
    
    //SKProductsRequestDelegate functions
    
    //Request the purchaseable products
    func requestProductData() {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: self.productIdentifiers)
            request.delegate = self
            request.start()
            print("Fetching products")
        } else {
            let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
                
                let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
                if url != nil
                {
                    UIApplication.sharedApplication().openURL(url!)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //Did receive products
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
            print("got a response from Apple")
            var products = response.products
            
            if (products.count != 0) {
                for var i = 0; i < products.count; i++
                {
                    self.product = products[i]
                    self.productsArray.append(product!)
                }
                self.tableView.reloadData()
            } else {
                print("No products found")
            }
            
            let invalidProducts = response.invalidProductIdentifiers
            
            for product in invalidProducts
            {
                print("Product not found: \(product)")
            }
        }
    
    //Buy request
    func buyProduct(item: Int) {
        print("Sending payment request to Apple")
        let payment = SKPayment(product: productsArray[item])
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    
    //SKPaymentTransactionObserver functions
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("Received Payment transaction from Apple")
            exitButton.enabled = false
            restoreButton.enabled = false
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Purchased:
                print("Transaction Approved")
                print("Product Identifier: \(transaction.payment.productIdentifier)")
                self.deliverProduct(transaction)
                //SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                queue.finishTransaction(transaction)
                exitButton.enabled = true
                restoreButton.enabled = true

            case SKPaymentTransactionState.Failed:
                print("Transaction Failed")
                //SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                queue.finishTransaction(transaction)
                exitButton.enabled = true
                restoreButton.enabled = true
                
            case SKPaymentTransactionState.Restored:
                print("Transaction Restored")
                print("Product Identifier: \(transaction.payment.productIdentifier)")
                self.deliverProduct(transaction)
                queue.finishTransaction(transaction)
                exitButton.enabled = true
                restoreButton.enabled = true
                
                
            default:
                break
            }
        }
    }
    
    
    func deliverProduct(transaction:SKPaymentTransaction) {
        
        if transaction.payment.productIdentifier == "com.pointblanckconsulting.Bang.packageA"
        {
            print("Package A Purchased")
            // Unlock Feature -- add Rebangs
            addRebangs(25)
        }
        else if transaction.payment.productIdentifier == "com.pointblanckconsulting.Bang.packageB"
        {
            print("Package B Purchased")
            // Unlock Feature -- add Rebangs
            addRebangs(60)
        }
        else if transaction.payment.productIdentifier == "com.pointblanckconsulting.Bang.packageC"
        {
            print("Package C Purchased")
            // Unlock Feature -- add Rebangs
            addRebangs(150)
        }
        else if transaction.payment.productIdentifier == "com.pointblanckconsulting.Bang.packageD"
        {
            print("Package D Purchased")
            // Unlock Feature -- add Rebangs
            addRebangs(350)
        }
        else if transaction.payment.productIdentifier == "com.pointblanckconsulting.Bang.packageE"
        {
            print("Package E Purchased")
            // Unlock Feature -- add Rebangs
            addRebangs(1500)
        }
        else if transaction.payment.productIdentifier == "com.pointblanckconsulting.Bang.adRemover"
        {
            print("Ads removed Purchased")
            // Unlock Feature -- remove ads
            removeAds()
        }
    }
    
    
    //Restore purchases
    func restorePurchases() {
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
        }
        //SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("Transactions Restored")


    }


}

extension IAPStoreTableViewController: ProductTableViewCellDelegate {
    

    func priceButtonPressed(indexPath: NSIndexPath) {
        buyProduct(indexPath.row)
    }
    
    
    
    
}



