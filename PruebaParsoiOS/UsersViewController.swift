//
//  ViewController.swift
//  PruebaParsoiOS
//
//  Created by Innova Media on 26/03/2018.
//  Copyright © 2018 Parso. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SQLite3

class UsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var filteredData = [JSONUserData]()
    var tableData = Array<JSONUserData>()
    
    var screenWidth: CGFloat = 0
    var screenHeight: CGFloat = 0
    
    var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //SVProgressHUD.setBackgroundColor(bgColor)
        SVProgressHUD.setForegroundColor(UIColor.gray)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.custom)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.init(rawValue: 1)!)
        SVProgressHUD.show(withStatus: "Cargando datos...")
        
        screenWidth = self.view.frame.size.width
        screenHeight = self.view.frame.size.height //568 52, 480 4s
        
        self.tableView.frame.size.width = screenWidth
        self.tableView.frame.size.height = screenHeight - 20
        
        tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        
        tableView.dataSource = self
        tableView.delegate = self
        
        getUsers()
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("ParsoDB.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS UsersTbl (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, firstname TEXT, lastname TEXT, email TEXT, picture TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
    }
    
    func getUsers() {
        self.tableData.removeAll()
        var title: String = ""
        var firstName: String = ""
        var lastName: String = ""
        var fullName: String = ""
        var picture: String = ""
        var email: String = ""
        
        Alamofire.request(Constants.urlServices + "/api?results=10", method: .get).responseJSON { response in
            
            let result = response.result
            var stmt: OpaquePointer?
            if response.response?.statusCode == 200 {
                if let dict = response.result.value as? [String : AnyObject] {
                    if let arrayDatos = dict["results"] as? [AnyObject] {
                        for var i in (0..<arrayDatos.count) {
                            if let name = arrayDatos[i]["name"] as? [String : AnyObject] {
                                title = name["title"] as! String
                                firstName = name["first"] as! String
                                lastName = name["last"] as! String
                                fullName = title.capitalized + ". " + firstName.capitalized + " " + lastName.capitalized
                                
                                print (fullName)
                            }
                            
                            if let pictureUser = arrayDatos[i]["picture"] as? [String : AnyObject] {
                                picture = pictureUser["large"] as! String
                            }
                            
                            email = arrayDatos[i]["email"] as! String
                            
                            //
                            //var stmt: OpaquePointer?
                            
                            //
                            let queryString = "INSERT INTO UsersTbl (title, firstname, lastname, email, picture) VALUES (?,?,?,?,?)"
                            
                            //
                            if sqlite3_prepare(self.db, queryString, -1, &stmt, nil) != SQLITE_OK{
                                let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                                print("error preparing insert: \(errmsg)")
                                return
                            }
                            
                            //
                            if sqlite3_bind_text(stmt, 1, title, -1, nil) != SQLITE_OK{
                                let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                                print("failure binding name: \(errmsg)")
                                return
                            }
                            
                            if sqlite3_bind_text(stmt, 2, firstName, -1, nil) != SQLITE_OK{
                                let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                                print("failure binding name: \(errmsg)")
                                return
                            }
                            
                            if sqlite3_bind_text(stmt, 3, lastName, -1, nil) != SQLITE_OK{
                                let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                                print("failure binding name: \(errmsg)")
                                return
                            }
                            
                            if sqlite3_bind_text(stmt, 4, email, -1, nil) != SQLITE_OK{
                                let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                                print("failure binding email: \(errmsg)")
                                return
                            }
                            
                            if sqlite3_bind_text(stmt, 5, picture, -1, nil) != SQLITE_OK{
                                let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                                print("failure binding picture: \(errmsg)")
                                return
                            }
                            
                            //
                            if sqlite3_step(stmt) != SQLITE_DONE {
                                let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                                print("failure inserting user: \(errmsg)")
                                return
                            }
                            
                            //self.tableData.append(JSONUserData(name: fullName, email: arrayDatos[i]["email"] as! String, picture: picture))
                        }
                        
                        //self.filteredData = self.tableData
                        //self.tableView.reloadData()
                    }
                    
                    self.getUsersLocal()
                }
            } else {
                let alertController = UIAlertController(title: "Parso", message: "Problemas al cargar usuarios", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    func getUsersLocal(){
        let queryString = "SELECT id, title, firstname, lastname, email, picture FROM UsersTbl"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(self.db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(self.db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            //let id = sqlite3_column_int(stmt, 0)
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let firstname = String(cString: sqlite3_column_text(stmt, 2))
            let lastname = String(cString: sqlite3_column_text(stmt, 3))
            let email = String(cString: sqlite3_column_text(stmt, 4))
            let picture = String(cString: sqlite3_column_text(stmt, 5))
            
            let fullName = title.capitalized + ". " + firstname.capitalized + " " + lastname.capitalized
            
            self.tableData.append(JSONUserData(name: firstname.capitalized, email: email, picture: picture))
        }
        
        self.filteredData = self.tableData
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! UsersTableViewCell
        
        cell.viewUser.frame.origin.x = 10
        cell.viewUser.frame.origin.y = 10
        cell.viewUser.frame.size.width = screenWidth - cell.viewUser.frame.origin.x - 10
        
        cell.lblUserName.frame.size.width = cell.viewUser.frame.size.width - cell.lblUserName.frame.origin.x - 10
        cell.lblUserEmail.frame.size.width = cell.viewUser.frame.size.width - cell.lblUserEmail.frame.origin.x - 10
 
        cell.lblUserName.text = self.filteredData[indexPath.row].name
        cell.lblUserEmail.text = self.filteredData[indexPath.row].email
        
        let imageURL = URL(string: self.filteredData[indexPath.row].picture as! String)!
        
        Alamofire.request(imageURL).responseData { (response) in
            if let data = response.data {
                cell.imgUserPicture.image = UIImage(data: data)
            }
        }
        
        cell.viewUser.layer.masksToBounds = false
        cell.viewUser.layer.shadowColor = UIColor(red: 212.0/255.0, green: 212.0/255.0, blue: 212.0/255.0, alpha: 1.0).cgColor
        cell.viewUser.layer.shadowOpacity = 0.3
        cell.viewUser.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
        cell.viewUser.layer.shadowRadius = 5.0
        cell.viewUser.layer.shadowPath = UIBezierPath(rect: cell.viewUser.bounds).cgPath
        cell.viewUser.layer.cornerRadius = 5
        
        cell.imgUserPicture.layer.borderWidth = 1
        cell.imgUserPicture.layer.borderColor = UIColor(red: 73/255.0, green: 105/255.0, blue: 150/255.0, alpha: 1.0).cgColor
        cell.imgUserPicture.layer.cornerRadius = cell.imgUserPicture.frame.height/2
        cell.imgUserPicture.clipsToBounds = true
        
        return cell
    }
}

