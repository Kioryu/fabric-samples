/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

type SmartContract struct {
}

type IceCream struct {
	Flavor string `json:"flavor"`
	Colour string `json:"colour"`
	Owner  string `json:"owner"`
}

func (s *SmartContract) Init(stub shim.ChaincodeStubInterface) peer.Response {
	//args := stub.GetStringArgs()
	//if len(args) != 2 {
	//	return shim.Error("Incorrect arguments. Expecting a key and a value")
	//}
	return shim.Success(nil)
}

func (s *SmartContract) Invoke(stub shim.ChaincodeStubInterface) peer.Response {

	function, args := stub.GetFunctionAndParameters()

	if function == "getIceCream" {
		return s.getIceCream(stub, args)
	} else if function == "newIceCream" {
		return s.newIceCream(stub, args)
	}

	return shim.Error("Invalid Smart Contract function name.")
}

// peer chaincode invoke -n fabice -c '{"Args":["getIceCream", "ICE0"]}' -C channelall
// peer chaincode query -C channelall -n fabice -c '{"Args":["getIceCream", "ICE0"]}'
// '{"Args":["getIceCream",
// "a" -> key  args[0]
// ]}'
func (s *SmartContract) getIceCream(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}
	iceCreamBytes, _ := stub.GetState(args[0])
	return shim.Success(iceCreamBytes)
}

// peer chaincode invoke -n fabice -c '{"Args":["newIceCream", "ICE0", "strawberry", "red", "User1"]}' -C channelall
// '{"Args":["newIceCream",
// "a",  -> key 	args[0]
// "1",  -> Flavor	args[1]
// "!",  -> Colour  args[2]
// "3"   -> Owner   args[3]
// ]}'
func (s *SmartContract) newIceCream(stub shim.ChaincodeStubInterface, args []string) peer.Response {

	if len(args) != 4 {
		return shim.Error("Incorrect number of arguments. Expecting 4")
	}

	var ice = IceCream{Flavor: args[1], Colour: args[2], Owner: args[3]}

	iceBytes, _ := json.Marshal(ice)
	stub.PutState(args[0], iceBytes)

	return shim.Success(nil)
}

func main() {
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
