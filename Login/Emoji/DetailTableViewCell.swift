

import UIKit

class DetailTableViewCell: UITableViewCell {
    
    // Outlets for tableView cell details

    @IBOutlet weak var modelImageView: UIImageView!
    
    
    @IBOutlet weak var modelTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
