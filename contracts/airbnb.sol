pragma solidity 0.5.0 ; 
pragma experimental ABIEncoderV2;

contract airbnb{
    
    address owner ; // airbnb平台
    uint index ; //目前平台總數
    
    struct House{
        
     address owner ;  //房東
     address borrower ; //房客
     string addr ; // 地址
     uint rent ; //租金
     uint avg ; //平均評分
     bool isBorrow ; //是否租借中
     bool exist ;  //是否存在
     bool payment; // 是否付款
    
    }
    
    struct Member{
        string name ; 
        uint age ;
        uint identity ; // 0 : 房東 1 : 房客
        uint rentCount ; // 出租房屋筆數
        mapping(uint => House) rentInfo ;
        
    }
    
    struct Comment{
        
        address borrower ; //房客
        string comment ; //評論
        uint score ; //評分
    }
    
    
    mapping(uint => Comment[]) comment ; //評論紀錄
    
    mapping(address => Member) member ; //會員資料儲存
    mapping(address => bool) register; //是否註冊
    
    
    modifier onlyLandlord{
        require( member[msg.sender].identity ==0 ,"you are not landlord");
        _;
    }
    
     modifier onlyTenant{
        require( member[msg.sender].identity ==1 ,"you are not tenant");
        _;
    }
    
    modifier onlyOwner{
        require(owner == msg.sender , "You are not owner");
        _;
    }
    
    modifier IsRegister{
        require(register[msg.sender] == false , " register yet"); 
        _;
        
    }
    modifier hadRegister{
        require(register[msg.sender] == true , " not register "); 
        _;
    }
    
    constructor() public {
        owner = msg.sender ;
    }
    
    //註冊會員
    function signUp(string memory _name , uint _age , uint _identity) IsRegister public {
        
        member[msg.sender].name = _name;
        member[msg.sender].age = _age;
        member[msg.sender].identity = _identity;
        member[msg.sender].rentCount = 0 ;
        register[msg.sender] = true;
        
    }
    
    //房東上架房屋
    function addHouse(string memory _addr, uint _rent ) hadRegister onlyLandlord public returns(uint) {
        index++;
        
        House memory house  = House({
            owner : msg.sender ,
            borrower : address(0x0) ,
            addr : _addr ,
            rent : _rent * 1 ether,
            avg : 0 ,
            isBorrow : false ,
            exist : true ,
            payment : false
        
        });
        
         member[msg.sender].rentInfo[index] = house ;
       
         return index ;
       
    }
    
    
    //房客訂房
    function booking(address payable _Landlord , uint _index, uint _rentday)  hadRegister onlyTenant payable public{
        
        require(member[_Landlord].rentInfo[_index].exist == true , " house not exist");
        require(member[_Landlord].rentInfo[_index].rent * _rentday == msg.value);
        member[_Landlord].rentInfo[_index].borrower = msg.sender ;
        member[_Landlord].rentInfo[_index].isBorrow = true ;
        member[_Landlord].rentInfo[_index].payment = true ;
        _Landlord.transfer(msg.value);
        
    }
    
    //房客退房
    function checkOut(address  _Landlord , uint _index, string memory _comment , uint _score) hadRegister onlyTenant public{
        require(member[_Landlord].rentInfo[_index].borrower == msg.sender , "you are not borrower ");
        member[_Landlord].rentInfo[_index].borrower = address(0x0);
        member[_Landlord].rentInfo[_index].isBorrow = false;
        member[_Landlord].rentInfo[_index].payment = false;
        
        //存入房客評分
        Comment memory c = Comment({
           borrower : msg.sender ,
           comment : _comment ,
           score : _score
        });
        
        
        comment[_index].push(c);
        
        //紀錄房間評分
        uint total = 0 ;
        for(uint i =0 ; i<comment[_index].length ; i++){
            total += comment[_index][i].score;
        }
        
         member[_Landlord].rentInfo[_index].avg = (total / comment[_index].length);
        
    }
    
    //房間評分留言
    function query_houseComment(uint _index) view public returns(Comment[] memory){
        
        return comment[_index];
        
    } 
   
   //房間相關資料
   function query_houseInfo(address _Landlord  , uint _index) view public returns(House memory){
       
       return member[_Landlord].rentInfo[_index];
   }
    
    
    
    function() external payable{}
    
    
}
