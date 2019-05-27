package main

import (
	"fmt"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
	"encoding/json"
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

	var book = bankbook{Owner: args[0], Pwd: args[1], Identifier: args[2], Balance: args[3]}

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
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	result, err := stub.GetState(args[0])
	if err != nil {
		return shim.Error(err.Error())
	}

	if result == nil {
		return shim.Error(fmt.Sprintf("Empty Key %s", args[0]))
	}

	return shim.Success(result)

}

func main() {
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
