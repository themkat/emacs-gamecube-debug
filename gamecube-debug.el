;;; gamecube-debug.el --- Gamecube debugging with USB Gecko

;; URL: https://github.com/themkat/emacs-gamecube-debug
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.4") (dap-mode "0.7") (f "0.20.0"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Simple utilities to make GameCube debugging more pleasant.
;; Uses dap-gdb-lldb for ease of use

;;; Code:

(require 'dap-mode)
(require 'dap-gdb-lldb)
(require 'f)


;; TODO: should we support broadband based network debugging? devkitpro seems to support it :O


(defcustom gamecube-debug-gdb-path "powerpc-eabi-gdb"
  "Path to the DevkitPPC GDB executable (including executable)."
  :group 'gamecube-debug
  :type 'string)

(defcustom gamecube-debug-projectfile "Makefile"
  "Project build file. Examples: Makefile, Cargo.toml etc."
  :group 'gamecube-debug
  :type 'string)

(defcustom gamecube-debug-usbgecko-device "/dev/cu.usbserial-GECKUSB0"
  "Device used for USB Gecko access."
  :group 'gamecube-debug
  :type 'string)

;; TODO: is some sort of custom executable path the best way to solve this?
;;       Does not feel like intricate logic to find the executable is worth it...
(defcustom gamecube-debug-custom-executable-path nil
  "Path (relative) to the executable we want to run.
Assumes elf-type. Unused if nil."
  :group 'gamecube-debug
  :type 'string)

(defun gamecube-debug--get-file-of-type (type directory)
  "Gets a file in directory `DIRECTORY' with the extension `TYPE' if it exists."
  (let ((filematches (f-glob (string-join (list "*." type)) directory)))
    (if (zerop (length filematches))
        (error (string-join (list "Could not find " type " file! Was compilation succesful?")))
      (car filematches))))

(defun gamecube-debug-program ()
  "Start a USB Gecko GDB debug session"
  (interactive)
  (let* ((project-directory (f-full (locate-dominating-file default-directory gamecube-debug-projectfile)))
         (elf-file (or gamecube-debug-custom-executable-path
                       (f-filename (gamecube-debug--get-file-of-type "elf" project-directory)))))
    (dap-debug (list :name "GameCube USB Gecko debug"
                     :type "gdbserver"
                     :request "attach"
                     :gdbpath gamecube-debug-gdb-path
                     :target gamecube-debug-usbgecko-device
                     :executable elf-file
                     :cwd project-directory))))

(provide 'gamecube-debug)
;;; gamecube-debug.el ends here
