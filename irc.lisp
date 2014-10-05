;;;; irc.lisp --- Logbot IRC client

;;; Copyright (C) 2014  Kan-Ru Chen (陳侃如)

;;; Author(s): Kan-Ru Chen (陳侃如) <kanru@kanru.info>

;;; Permission is hereby granted, free of charge, to any person obtaining a
;;; copy of this software and associated documentation files (the "Software"),
;;; to deal in the Software without restriction, including without limitation
;;; the rights to use, copy, modify, merge, publish, distribute, sublicense,
;;; and/or sell copies of the Software, and to permit persons to whom the
;;; Software is furnished to do so, subject to the following conditions:

;;; The above copyright notice and this permission notice shall be included in
;;; all copies or substantial portions of the Software.

;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;;; DEALINGS IN THE SOFTWARE.

;;;; Commentary:

;;; 

;;;; Code:

(in-package #:logbot)

(defclass logbot (irc:client)
  ((%db :initarg :database
        :accessor logbot-db)))

(defun irc-logbot (pathname server port nick channels)
  (let* ((usocket (usocket:socket-connect server port))
         (stream (usocket:socket-stream usocket))
         (conn (irc:make-connection stream))
         (db (database-open pathname))
         (client (make-instance 'logbot
                                :nick nick
                                :user "logbot"
                                :realname "Logbot-Lisp"
                                :channels channels
                                :database db)))
    (unwind-protect
         (irc:with-connection (conn)
           (irc:connect-run-main-loop client))
      (database-close db))))

(defmethod irc:handle-message ((client logbot) (msg irc-message:privmsg))
  (log-message (logbot-db client)
               (first (irc-message:message-args msg))
               (getf (irc-message:message-prefix msg) :nickname)
               "PRIVMSG"
               (second (irc-message:message-args msg))))

;;; irc.lisp ends here

;;; Local Variables:
;;; mode: lisp
;;; End:
