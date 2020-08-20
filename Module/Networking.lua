local Networking = {
    Clients = {};
    Incoming = {};
    Outgoing = {};
    IP = "";
    Port = 8080;
    Socket = nil;

    Create = function(self, IP, Port)
        local Client = setmetatable({}, { __index = self })
        Client.IP = IP
        Client.Port = Port
        Client.Socket = network.Socket('UDP');

        table.insert(self.Clients, Client)
        return Client
    end;

    Send = function(self, data, callback)
        callback = callback or function() end
        data = data or ""

        self.Socket:SendTo( self.IP, self.Port, data )
        table.insert(self.Outgoing, callback)
    end;
}

local TickInterval = 2 % 2
callbacks.Register( "Draw", function()
    TickInterval = globals.TickCount() % 2
    if TickInterval == 0 then
        for _, client in next, Networking.Clients do
            local msg, ip, port = client.Socket:RecvFrom( client.IP, client.Port, 10000 );
            if msg then
                local length = 0
                for i=#msg, 1, -1 do
                    if string.byte( msg:sub(i, i) ) ~= 0 then
                        length = i
                        break
                    end
                end
                msg = msg:sub(1, length)
                table.insert( client.Incoming, msg )
            end
        end
    
        for _, client in next, Networking.Clients do
            for _, data in next, client.Incoming do
                client.Outgoing[_](data)
                table.remove(client.Incoming, _)
                table.remove(client.Outgoing, _)
            end
        end
    end
end )

return Networking
