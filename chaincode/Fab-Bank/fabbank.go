package main

import (
	"fmt"

	"crypto/sha512"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
	"encoding/json"
	"strconv"
)

type SmartContract struct {
}

type bankbook struct {
	Owner      string `json:"owner"`
	Pwd        string `json:"pwd"`
	Identifier string `json:"identifier"`
	Balance    string `json:"balance"`
}

func (s *SmartContract) Init(stub shim.ChaincodeStubInterface) peer.Response {
	return shim.Success(nil)
}

func (s *SmartContract) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
	function, args := stub.GetFunctionAndParameters()

	if function == "open" {
		return s.open(stub, args)
	} else if function == "getBankBook" {
		return s.getBankBook(stub, args)
	} else if function == "sendMoney" {
		return s.sendMoney(stub, args)
	} else if function == "deposit" {
		return s.deposit(stub, args)
	} else if function == "withdraw" {
		return s.withdraw(stub, args)
	}

	return shim.Error("Invalid Smart Contract function name.")
}

// from(key), pwd, identifier, value
func (s *SmartContract) open(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 4 {
		return shim.Error("Incorrect number of arguments. Expecting 4")
	}

	from := args[0]
	pwd := args[1]
	identifier := args[2]
	value := args[3]

	result, err := stub.GetState(from)
	if err != nil {
		return shim.Error(err.Error())
	}

	if result != nil {
		return shim.Error(fmt.Sprintf("%s - %s : %s", "It already exists.", "key", from))
	}

	hashedPWD := generatePWD(pwd)

	var book = bankbook{Owner: from, Pwd: hashedPWD, Identifier: identifier, Balance: value}

	bookBytes, err := json.Marshal(book)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(from, bookBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(result)
}

// from(key), pwd
func (s *SmartContract) getBankBook(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	from := args[0]
	pwd := args[1]

	result, err := stub.GetState(from)
	if err != nil {
		return shim.Error(err.Error())
	}

	if result == nil {
		return shim.Error(fmt.Sprintf("Empty Key %s", from))
	}

	err = checkPWD(result, pwd)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(result)

}

// from, pwd, to, value
func (s *SmartContract) sendMoney(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 4 {
		return shim.Error("Incorrect number of arguments. Expecting 4")
	}

	from := args[0]
	pwd := args[1]
	to := args[2]
	value := args[3]

	fromResult, err := stub.GetState(from)
	if err != nil {
		return shim.Error(err.Error())
	}

	if fromResult == nil {
		return shim.Error(fmt.Sprintf("Empty Key %s", from))
	}

	err = checkPWD(fromResult, pwd)
	if err != nil {
		return shim.Error(err.Error())
	}

	toResult, err := stub.GetState(to)
	if err != nil {
		return shim.Error(err.Error())
	}

	if toResult == nil {
		return shim.Error(fmt.Sprintf("Empty To %s", to))
	}

	fromBookByte, toBookByte, err := modifyBooksSendValue(fromResult, toResult, value)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(from, fromBookByte)
	if err != nil {
		shim.Error(err.Error())
	}

	err = stub.PutState(to, toBookByte)
	if err != nil {
		shim.Error(err.Error())
	}

	return shim.Success([]byte("Money has been transferred."))
}

// owner(key), pwd, value
func (s *SmartContract) deposit(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3")
	}

	owner := args[0]
	pwd := args[1]
	value := args[2]

	ownerResult, err := stub.GetState(owner)
	if err != nil {
		return shim.Error(err.Error())
	}

	if ownerResult == nil {
		return shim.Error(fmt.Sprintf("Empty Key %s", ownerResult))
	}

	err = checkPWD(ownerResult, pwd)
	if err != nil {
		return shim.Error(err.Error())
	}

	modifiedBook, err := modifyBookBalance(0, ownerResult, value)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(owner, modifiedBook)
	if err != nil {
		shim.Error(err.Error())
	}

	return shim.Success([]byte("Deposit completed."))
}

// owner, pwd, value
func (s *SmartContract) withdraw(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3")
	}

	owner := args[0]
	pwd := args[1]
	value := args[2]

	ownerResult, err := stub.GetState(owner)
	if err != nil {
		return shim.Error(err.Error())
	}

	if ownerResult == nil {
		return shim.Error(fmt.Sprintf("Empty Key %s", ownerResult))
	}

	err = checkPWD(ownerResult, pwd)
	if err != nil {
		return shim.Error(err.Error())
	}

	result, err := modifyBookBalance(1, ownerResult, value)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(owner, result)
	if err != nil {
		shim.Error(err.Error())
	}

	return shim.Success([]byte("complete withdrawal"))
}

func generatePWD(pwd string) (string) {
	s512 := sha512.New()
	s512.Write([]byte(pwd))
	bs := s512.Sum(nil)
	return fmt.Sprintf("%x", bs)
}

func checkPWD(bookByte []byte, pwd string) error {
	bk := bankbook{}
	json.Unmarshal(bookByte, &bk)

	if bk.Pwd != generatePWD(pwd) {
		return fmt.Errorf("The password is incorrect.")
	}

	return nil
}

// operatorType 0 == +
// operatorType 1 == -
func modifyBookBalance(operatorType int, result []byte, value string) ([]byte, error) {
	book := bankbook{}

	json.Unmarshal(result, &book)

	ownerBalance, err := strconv.ParseInt(book.Balance, 10, 64)
	if err != nil {
		return nil, err
	}

	depositBalance, err := strconv.ParseInt(value, 10, 64)
	if err != nil {
		return nil, err
	}

	var resultBalance int64
	if operatorType == 0 {
		resultBalance = ownerBalance + depositBalance
	} else if operatorType == 1 {
		resultBalance = ownerBalance - depositBalance
		if resultBalance < 0 {
			return nil, fmt.Errorf("%s", "no money.")
		}
	}

	book.Balance = fmt.Sprintf("%d", resultBalance)

	ownerBookByte, err := json.Marshal(book)
	if err != nil {
		return nil, err
	}

	return ownerBookByte, nil
}

func modifyBooksSendValue(fromResult, toResult []byte, sendValue string) ([]byte, []byte, error) {
	fromBook := bankbook{}
	toBook := bankbook{}

	json.Unmarshal(fromResult, &fromBook)
	json.Unmarshal(toResult, &toBook)

	fromBalance, err := strconv.ParseInt(fromBook.Balance, 10, 64)
	if err != nil {
		return nil, nil, err
	}

	toBalance, err := strconv.ParseInt(toBook.Balance, 10, 64)
	if err != nil {
		return nil, nil, err
	}

	sendBalance, err := strconv.ParseInt(sendValue, 10, 64)
	if err != nil {
		return nil, nil, err
	}

	resultBalance := fromBalance - sendBalance
	if resultBalance < 0 {
		return nil, nil, fmt.Errorf("%s", "no money.")
	}

	fromBook.Balance = fmt.Sprintf("%d", resultBalance)
	toBook.Balance = fmt.Sprintf("%d", toBalance+sendBalance)

	fromBookByte, err := json.Marshal(fromBook)
	if err != nil {
		return nil, nil, err
	}

	toBookByte, err := json.Marshal(toBook)
	if err != nil {
		return nil, nil, err
	}

	return fromBookByte, toBookByte, nil
}

func main() {
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
