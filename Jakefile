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
    OS.system(["rm", "-f", SYSTEM.prefix + "/bin/cucapp"])
    OS.system(["rm", "-rf", SYSTEM.prefix + "/packages/cucapp/"])
});

task ("install", ["clean"], function()
{
    OS.system(["gem", "build", "cucapp.gemspec"]);
    OS.system(["gem", "install", "cucapp"]);

    OS.system(["mkdir", "-p", SYSTEM.prefix + "/packages/cucapp/"])
    OS.system(["cp", "-r", "lib/cucapp/bin", SYSTEM.prefix + "/packages/cucapp/bin"]);
    OS.system(["cp", "-r", ".", SYSTEM.prefix + "/packages/cucapp/Cucapp"]);
    OS.system(["cp", "-r", "lib/cucapp/Resources", SYSTEM.prefix + "/packages/cucapp/"]);
    OS.system(["cp", "-r", "package.json", SYSTEM.prefix + "/packages/cucapp/"]);
    OS.system(["ln", "-s", SYSTEM.prefix + "/packages/cucapp/bin/cucapp", SYSTEM.prefix + "/bin/cucapp"])
    print("Installation done of cucapp! Have fun in testing now :)")
});
