# Lua-Object-Factory
Designed using RBX.lua.

This generic object factory is the product of an evolutionary factory learning process. Built entirely from scratch, with the only exception being a functionally modified version of [Quenty's Signal](https://github.com/Quenty/NevermoreEngine/blob/6ca66a994dba630ad9ac0e2208ac3b8b6630b053/Modules/Events/Signal.lua).

# Components
## ClassOrganizer.lua
- Acquired upon initial requisition of Factory.lua. ClassOrganizer requires network-proper templates into a dictionary (If a client has `require`d Factory, then only Client_ClassName modules will be cast into the dictionary. If server, then Server_ClassName modules). 
- Also places each object's read-only tables into a separate dictionary.

## Factory.lua
1. `Create`
       - hee
