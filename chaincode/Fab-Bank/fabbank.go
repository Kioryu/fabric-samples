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
	}

	return shim.Error("Invalid Smart Contract function name.")
}

// from(key), pwd, identifier, balance
func (s *SmartContract) open(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 4 {
		return shim.Error("Incorrect number of arguments. Expecting 4")
	}

	result, err := stub.GetState(args[0])
	if err != nil {
		return shim.Error(err.Error())
	}

	if result != nil {
		return shim.Error(fmt.Sprintf("%s - %s : %s", "It already exists.", "key", args[0]))
	}

	hashedPWD := generatePWD(args[1])

	var book = bankbook{Owner: args[0], Pwd: hashedPWD, Identifier: args[2], Balance: args[3]}

	bookBytes, err := json.Marshal(book)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(args[0], bookBytes)
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

	result, err := stub.GetState(args[0])
	if err != nil {
		return shim.Error(err.Error())
	}

	if result == nil {
		return shim.Error(fmt.Sprintf("Empty Key %s", args[0]))
	}

	err = checkPWD(result, args[1])
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

	fromBook := bankbook{}
	toBook := bankbook{}

	json.Unmarshal(fromResult, &fromBook)
	json.Unmarshal(toResult, &toBook)

	fromBalance, err := strconv.ParseInt(fromBook.Balance, 10, 64)
	if err != nil {
		return shim.Error(err.Error())
	}

	toBalance, err := strconv.ParseInt(toBook.Balance, 10, 64)
	if err != nil {
		return shim.Error(err.Error())
	}

	sendValue, err := strconv.ParseInt(value, 10, 64)
	if err != nil {
		return shim.Error(err.Error())
	}

	resultBalance := fromBalance - sendValue
	if resultBalance < 0 {
		return shim.Error(fmt.Sprintf("%s", "no money."))
	}

	fromBook.Balance = fmt.Sprintf("%d", resultBalance)
	toBook.Balance = fmt.Sprintf("%d", toBalance+sendValue)

	fromBookByte, err := json.Marshal(fromBook)
	if err != nil {
		shim.Error(err.Error())
	}

	toBookByte, err := json.Marshal(toBook)
	if err != nil {
		shim.Error(err.Error())
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

func main() {
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
