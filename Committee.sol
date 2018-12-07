pragma solidity ^0.4.16;
import "./PickYourNumber.sol";
contract Committee is PickNumber{
   constructor (
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) PickNumber(initialSupply, tokenName, tokenSymbol) public {}

address[] public Committeelist;
 function C_joingame  () public {
        require(!joining[msg.sender]);
        joining[msg.sender]=true;
        if(start==0)
            _triggergivewinner_cooldowntime();
        _transfer(owner,msg.sender,100);
        playerlist.push(msg.sender);
        Committeelist.push(msg.sender);
        start=1;
    }
    
        //取得獲獎數字,將玩家所有下注之數字加總(包含Comittee)+上block的info
        //相加取hash在%101
     function C_getWinnumber()public view returns(uint){ 
        uint total;
        uint winnumber;
        for(uint i=0;i<101;i++){
          total+= number[i]*i;
        }
        uint n;
        uint d;
        (n,d)=C_getBlockinfo();
        winnumber=uint(keccak256(total+n+d))%101;
        return winnumber;
    }
        //取得得獎者
        function C_getWinner() public view returns(address[]){
        address[] memory winlist;
        uint winnernum=C_getWinnumber();
       winlist=NumToOwner[winnernum];
       return winlist;
    }
    //獲得blockinfo time,number,difficulty
    function C_getBlockinfo()public view returns(uint,uint){
        uint number;
        uint diff;
       number=block.number;
       diff=uint(block.difficulty);
       return (number,diff);
    }
    //派獎
    function C_givewinner()onlyOwner public  {
       require(givewinnerReady());
       uint winnerprize=getWinprize();
       address[] memory winnerlist =C_getWinner();
       uint winnercount=winnerlist.length;
       uint winnernumber=C_getWinnumber();
       uint num_count=number[winnernumber];
       uint averageprize=winnerprize/num_count;
       require(winnerprize>=totalnum);
       require(winnercount!=0);
       for(uint i=0;i<winnercount;i++){
         uint winner_numcount= OwnerNumCount[winnerlist[i]][winnernumber];
           _transfer(address(this),winnerlist[i],averageprize*winner_numcount-1);
       }
       _triggergivewinner_cooldowntime();
           reset();
    }
}
