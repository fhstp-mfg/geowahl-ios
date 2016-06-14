//
//  ViewController.swift
//  geowahl-ios
//
//  Created by Patrick Eberhardt on 30.05.16.
//  Copyright © 2016 Patrick Eberhardt. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController {

    @IBOutlet weak var pieChartView: PieChartView!
    var data: AnyObject? = nil
    var namesArray: [String] = []
    var percentArray: [Double] = []
    var colorArray: [UIColor] = []
    
    enum Parties: String {
        case Griss
        case Hofer
        case Hundstorfer
        case Khol
        case Lugner
        case VdB
        case SPOE
        case FPOE
        case OEVP
        case GRUE
        case NEOS
        case FRANK
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = data!["name"] as! String
        // Do any additional setup after loading the view, typically from a nib.
        //print(data!["results"]!![0])
        for result in data!["results"]!! as! [AnyObject] {
            if result["name"] as! String == Parties.GRUE.rawValue || result["name"] as! String == Parties.VdB.rawValue {
                colorArray.append(UIColor.init(red: 120/255, green: 175/255, blue: 53/255, alpha: 1.0))
            }
            if result["name"] as! String == Parties.SPOE.rawValue || result["name"] as! String == Parties.Hundstorfer.rawValue {
                colorArray.append(UIColor.init(red: 243/255, green: 17/255, blue: 55/255, alpha: 1.0))
            }
            if result["name"] as! String == Parties.OEVP.rawValue || result["name"] as! String == Parties.Khol.rawValue {
                colorArray.append(UIColor.init(red: 54/255, green: 54/255, blue: 54/255, alpha: 1.0))
            }
            if result["name"] as! String == Parties.NEOS.rawValue {
                colorArray.append(UIColor.init(red: 234/255, green: 61/255, blue: 136/255, alpha: 1.0))
            }
            if result["name"] as! String == Parties.FRANK.rawValue {
                colorArray.append(UIColor.init(red: 248/255, green: 227/255, blue: 35/255, alpha: 1.0))
            }
            if result["name"] as! String == Parties.Griss.rawValue {
                colorArray.append(UIColor.init(red: 186/255, green: 186/255, blue: 186/255, alpha: 1.0))
            }
            if result["name"] as! String == Parties.Lugner.rawValue {
                colorArray.append(UIColor.init(red: 119/255, green: 6/255, blue: 140/255, alpha: 1.0))
            }
            if result["name"] as! String == Parties.FPOE.rawValue || result["name"] as! String == Parties.Hofer.rawValue {
                colorArray.append(UIColor.init(red: 14/255, green: 66/255, blue: 142/255, alpha: 1.0))
            }
            namesArray.append(result["name"] as! String)
            percentArray.append(result["percent"] as! Double)
        }
        
        setChart(namesArray, values: percentArray, colors: colorArray)
        setAttributes(pieChartView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChart(dataPoints: [String], values: [Double], colors: [UIColor]) {
        pieChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        //var colors: [UIColor] = []
        
        //        for i in 0..<dataPoints.count {
        //            let red = Double(arc4random_uniform(256))
        //            let green = Double(arc4random_uniform(256))
        //            let blue = Double(arc4random_uniform(256))
        //
        //            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
        //            colors.append(color)
        //        }
        
        pieChartDataSet.colors = colors
        pieChartDataSet.sliceSpace = 2.0
    }
    
    func setAttributes(view: PieChartView){
        view.legend.enabled = true
        view.legend.formSize = 16.0
        view.descriptionText = ""
        //view.userInteractionEnabled = false
        view.drawSliceTextEnabled = false
        view.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutBack)
    }
    
    
}

