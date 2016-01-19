/*
* Copyright 2010, Daniel Parnell, Automagic Software Pty Ltd All rights reserved.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>
*/

var ENV = require("system").env,
    FILE = require("file"),
    JAKE = require("jake"),
    task = JAKE.task,
    FileList = JAKE.FileList,
    app = require("cappuccino/jake").app,
    configuration = ENV["CONFIG"] || ENV["CONFIGURATION"] || ENV["c"] || "Debug",
    OS = require("os"),
    SYSTEM = require("system");

function printResults(configuration)
{
    print("----------------------------");
    print(configuration+" app built at path: "+FILE.join("Build", configuration, "Cucumber"));
    print("----------------------------");
}

task ("clean", function()
{
    var narwhal = ENV["CAPP_INSTALL_DIR"] || SYSTEM.prefix;

    OS.system(["rm", "-f", narwhal + "/bin/cucapp"])
    OS.system(["rm", "-rf", narwhal + "/packages/cucapp/"])
});

task ("install", ["clean"], function()
{
    var narwhal = ENV["CAPP_INSTALL_DIR"] || SYSTEM.prefix;

    OS.system(["gem", "build", "cucapp.gemspec"]);
    
    if (OS.system(["gem", "install", "cucapp"]))
    {
        print("Unable to install gems with current user. Trying again with sudo (you may need to enter your password)...");
        OS.system(["sudo", "gem", "install", "cucapp"])
    }

    OS.system(["mkdir", "-p", narwhal + "/packages/cucapp/"])
    OS.system(["cp", "-r", "lib/cucapp/bin", narwhal + "/packages/cucapp/bin"]);
    OS.system(["cp", "-r", ".", narwhal + "/packages/cucapp/Cucapp"]);
    OS.system(["cp", "-r", "lib/cucapp/Resources", narwhal + "/packages/cucapp/"]);
    OS.system(["cp", "-r", "package.json", narwhal + "/packages/cucapp/"]);
    OS.system(["ln", "-s", narwhal + "/packages/cucapp/bin/cucapp", narwhal + "/bin/cucapp"])
    print("Cucapp installation done! Have fun in testing now :)")
});
