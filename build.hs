module Build where

import Development.Shake
import Development.Shake.FilePath
import Development.Shake.Util

buildDir :: FilePath
buildDir = "make"

projectName :: String
projectName = "hello"

sources :: [FilePath]
sources = [ "crt0.s"  -- This must be first
          , "hello.c"
          ]

main :: IO ()
main = shakeArgs shakeOptions{shakeFiles = buildDir} $ do
    want [buildDir </> projectName <.> "gba"]

    phony "clean" $ do
      putNormal "Cleaning files in build directory"
      removeFilesAfter buildDir ["//*"]

    buildDir </> projectName <.> "gba" %> \gba -> do
      let elf = gba -<.> "elf"
      need [elf]
      cmd "arm-none-eabi-objcopy" "-O" "binary" elf gba

    buildDir </> projectName <.> "elf" %> \elf -> do
      let os = [buildDir </> s <.> "o" | s <- sources]
      need os
      cmd "arm-none-eabi-ld" os "-o" elf "--script" "linker.ld"

    buildDir <//> "*" <.> "s.o" %> \o -> do
      let s = dropDirectory1 . dropExtension $ o 
          m = o -<.> "m"
      () <- cmd "arm-none-eabi-as" s "-o" o "-MD" m
      needMakefileDependencies m

    buildDir <//> "*" <.> "c.o" %> \o -> do
      let c = dropDirectory1 . dropExtension $ o 
          m = o -<.> "m"
      () <- cmd "clang" "-target" "arm-none-eabi"
                        "-mthumb"
                        "-march=armv4t"
                        "-mcpu=arm7tdmi"
                        "-c" c 
                        "-o" o 
                        "-MMD" "-MF" m
                        "-O2"
                        "-Wall"
      needMakefileDependencies m
