// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

/**
 * 结构体，类似java对象
 */
contract Structs {
    struct Car {
        string model;
        uint year;
        address owner;
    }

    Car public car;
    Car[] public cars;
    mapping(address => Car[]) public carsByOwner;

    function examples() external {
        Car memory toyota = Car("toyota", 1990, msg.sender);
        Car memory benchi = Car({year:1220, model : "benchi", owner: msg.sender});
        Car memory baoma;
        baoma.year = 1802;
        baoma.model = "baoma";
        baoma.owner = msg.sender;

        cars.push(toyota);
        cars.push(benchi);
        cars.push(baoma);

        cars.push(Car("jili", 2020, msg.sender));

        Car storage _car = cars[0];
        _car.year = 1750;

        delete _car.owner;
        delete cars[1];
    }
}