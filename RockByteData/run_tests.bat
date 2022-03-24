@ECHO OFF

START /b busted .\tests\test_error.lua
START /b busted .\tests\test_base.lua
START /b busted .\tests\test_number.lua
START /b busted .\tests\test_string.lua
START /b busted .\tests\test_table.lua
START /b busted .\tests\test_time.lua