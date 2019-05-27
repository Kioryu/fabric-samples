package main

import (
	"fmt"

	"crypto/sha512"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
	"encoding/json"
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
	}

	return shim.Error("Invalid Smart Contract function name.")
}

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

func main() {
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
