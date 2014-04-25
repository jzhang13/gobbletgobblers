;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname proj1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require 2htdp/image)
(require racket/match)

;;;; a size is either 1, 2, or 3,
;; representing small, medium, large in that order

;; a player is either 'blue or 'orange

;; a square is a natural number between 0 and 8 inclusive

;; a piece is a (make-piece s p) where
;; - s is a size, and
;; - p is a player
(define-struct piece (size player))

;; an intro is a (make-intro p s) where
;; - p is a piece, and
;; - s is a square
(define-struct intro (piece square))

;; a shift is a (make-shift src dst) where
;; - src and dst are both squares
(define-struct shift (src dst))

;; a move is either
;; - an intro, or
;; - a shift

;; an inventory is a (listof piece)

;; a board is a (listof (listof piece)) of length exactly 9
;; representing the squares of the board.  Each square is represented
;; by a list of pieces, where the pieces are ordered from outermost
;; (i.e., biggest) to innermost (smallest).  An square with no pieces
;; is represented by the empty list.
;; The order of the 9 items in the list corresponds to the 
;; squares on the board as follows:
;; 0 1 2
;; 3 4 5
;; 6 7 8

;; a game is a (make-game next oinv binv board) where
;; - next is a player, 
;; - oinv ("orange inventory") is an inventory,
;; - binv ("blue inventory") is an inventory, and
;; - board is a board (per definition above)
(define-struct game (next oinv binv board))

(define testgame1 (make-game 'orange 
                             (list (make-piece 1 'orange)
                                   (make-piece 1 'orange)
                                   (make-piece 2 'orange)
                                   (make-piece 3 'orange))
                             (list (make-piece 1 'blue)
                                   (make-piece 2 'blue)
                                   (make-piece 3 'blue)
                                   (make-piece 3 'blue))
                             (list (list (make-piece 1 'blue))
                                   empty
                                   empty
                                   (list (make-piece 3 'orange) (make-piece 2 'blue))
                                   empty
                                   empty
                                   (list (make-piece 2 'orange))
                                   empty
                                   empty)))

(define testgame2 (make-game 'blue
                             (list (make-piece 1 'orange)
                                   (make-piece 1 'orange)
                                   (make-piece 3 'orange))
                             (list (make-piece 1 'blue)
                                   (make-piece 3 'blue)
                                   (make-piece 3 'blue))
                             (list (list (make-piece 1 'blue) (make-piece 1 'orange))
                                   empty
                                   empty
                                   (list (make-piece 2 'orange) (make-piece 3 'blue))
                                   empty
                                   empty
                                   (list (make-piece 2 'orange))
                                   empty
                                   empty)))

(define testgame3 (make-game 'orange 
                             (list (make-piece 1 'orange)
                                   (make-piece 1 'orange)
                                   (make-piece 3 'orange))
                             (list (make-piece 1 'blue)
                                   (make-piece 1 'blue)
                                   (make-piece 2 'blue)
                                   (make-piece 3 'blue)
                                   (make-piece 3 'blue))
                             (list (list (make-piece 2 'orange))
                                   empty
                                   empty
                                   (list (make-piece 3 'orange) (make-piece 2 'blue))
                                   empty
                                   empty
                                   (list (make-piece 2 'orange))
                                   empty
                                   empty)))

(define testgame4 (make-game 'blue
                             (list (make-piece 1 'orange)
                                   (make-piece 1 'orange)
                                   (make-piece 3 'orange))
                             (list (make-piece 1 'blue)
                                   (make-piece 1 'blue)
                                   (make-piece 2 'blue)
                                   (make-piece 3 'blue))
                             (list (list (make-piece 3 'blue) (make-piece 2 'orange))
                                   empty
                                   empty
                                   (list (make-piece 3 'orange) (make-piece 2 'blue))
                                   empty
                                   empty
                                   (list (make-piece 2 'orange))
                                   empty
                                   empty)))
(define testgame5 (make-game 'orange
                             (list (make-piece 1 'orange)
                                   (make-piece 1 'orange)
                                   (make-piece 3 'orange))
                             (list (make-piece 3 'blue)
                                   (make-piece 1 'blue)
                                   (make-piece 1 'blue)
                                   (make-piece 2 'blue)
                                   (make-piece 3 'blue))
                             (list (list (make-piece 2 'orange))
                                   empty
                                   empty
                                   (list (make-piece 3 'orange) (make-piece 2 'blue))
                                   empty
                                   empty
                                   (list (make-piece 2 'orange))
                                   empty
                                   empty)))
(define testgame6 (make-game 'orange
                             (list (make-piece 1 'orange)
                                   (make-piece 1 'orange)
                                   (make-piece 3 'orange))
                             (list (make-piece 1 'blue)
                                   (make-piece 1 'blue)
                                   (make-piece 2 'blue))
                             (list (list (make-piece 3 'blue) (make-piece 2 'orange))
                                   empty
                                   empty
                                   (list (make-piece 3 'orange) (make-piece 2 'blue))
                                   empty
                                   empty
                                   (list (make-piece 3 'blue) (make-piece 2 'orange))
                                   empty
                                   empty)))
;; new-game : player -> game
;; creates an initial game state, both inventories are full
;; no pieces on the board
(define (new-game p1)
  (local {(define oinv (list (make-piece 1 'orange)
                             (make-piece 1 'orange)
                             (make-piece 2 'orange)
                             (make-piece 2 'orange)
                             (make-piece 3 'orange)
                             (make-piece 3 'orange)))
          (define binv (list (make-piece 1 'blue)
                             (make-piece 1 'blue)
                             (make-piece 2 'blue)
                             (make-piece 2 'blue)
                             (make-piece 3 'blue)
                             (make-piece 3 'blue)))
          (define nboard (list (list empty)
                               (list empty)
                               (list empty)
                               (list empty)
                               (list empty)
                               (list empty)
                               (list empty)
                               (list empty)
                               (list empty)))}
    (make-game p1 oinv binv nboard)))
(check-expect (new-game 'blue) 
              (make-game 'blue 
                         (list (make-piece 1 'orange)
                               (make-piece 1 'orange)
                               (make-piece 2 'orange)
                               (make-piece 2 'orange)
                               (make-piece 3 'orange)
                               (make-piece 3 'orange))
                         (list (make-piece 1 'blue)
                               (make-piece 1 'blue)
                               (make-piece 2 'blue)
                               (make-piece 2 'blue)
                               (make-piece 3 'blue)
                               (make-piece 3 'blue))
                         (list (list empty)
                               (list empty)
                               (list empty)
                               (list empty)
                               (list empty)
                               (list empty)
                               (list empty)
                               (list empty)
                               (list empty))))
;; pieces-at : board square -> (listof piece)
;; returns the list of pieces at the given square
(define (pieces-at b sq)
  (cond [(= sq 0) (first b)]
        [else (pieces-at (rest b) (- sq 1))]))
(check-expect (pieces-at (list (list empty)
                               (list empty)
                               (list (make-piece 3 'orange)
                                     (make-piece 2 'blue)
                                     (make-piece 1 'orange))
                               (list empty)
                               (list empty)
                               (list empty)
                               (list empty)
                               (list empty)
                               (list empty)) 2) (list (make-piece 3 'orange)
                                                      (make-piece 2 'blue)
                                                      (make-piece 1 'orange)))

;; numlist : size player list --> num
;; returns the number of pieces of a size and color in a list
(define (numlist s p list)
  (cond [(or (empty? list) (empty? (first list))) 0]
        [(and (= (piece-size (first list)) s)
              (symbol=? (piece-player (first list)) p)) (+ 1 (numlist s p (rest list)))]
        [else (numlist s p (rest list))]))
(check-expect (numlist 1 'orange (list (make-piece 1 'orange)
                                       (make-piece 2 'orange)
                                       (make-piece 3 'orange))) 1)

;; numboard : size player board --> num
;; returns the number of pieces of a size in a board
(define (numboard s p b)
  (cond [(empty? b) 0]
        [else (+ (numlist s p (first b)) (numboard s p (rest b)))]))
(check-expect (numboard 1 'orange (list (list (make-piece 1 'orange))
                                         (list (make-piece 1 'blue))
                                         (list (make-piece 1 'orange))
                                         empty
                                         empty)) 2)

;; pieces-valid? : game -> bool
;; tests that the collection of pieces in the game is valid
(define (pieces-valid? g)
  (local {(define onum1 (+ (numlist 1 'orange (game-oinv g)) (numboard 1 'orange (game-board g))))
          (define onum2 (+ (numlist 2 'orange (game-oinv g)) (numboard 2 'orange (game-board g))))
          (define onum3 (+ (numlist 3 'orange (game-oinv g)) (numboard 3 'orange (game-board g))))
          (define bnum1 (+ (numlist 1 'blue (game-binv g)) (numboard 1 'blue (game-board g))))
          (define bnum2 (+ (numlist 2 'blue (game-binv g)) (numboard 2 'blue (game-board g))))
          (define bnum3 (+ (numlist 3 'blue (game-binv g)) (numboard 3 'blue (game-board g))))}
    (and (= 222 (+ (+ onum1 (* onum2 10))
                   (* onum3 100)))
         (= 222 (+ (+ bnum1 (* bnum2 10))
                   (* bnum3 100))))))
(check-expect (pieces-valid? testgame1) true)
(check-expect (pieces-valid? testgame2) false)

;; piecesat-valid? : (listof pieces) -> bool
;; tests whether a list of pieces at a square is valid
(define (sq-valid? sq)
  (cond [(or (empty? sq) (= (length sq) 1)) #t]
        [(<= (length sq) 3) (and (> (piece-size (first sq)) (piece-size (first (rest sq))))
                                 (sq-valid? (rest sq)))]))
(check-expect (sq-valid? (list (make-piece 3 'orange) (make-piece 2 'blue) (make-piece 1 'orange))) #t)
(check-expect (sq-valid? (list (make-piece 3 'orange) (make-piece 3 'blue))) #f)

;; squares-valid? : board -> bool
;; test whether all squares on the board are in a legal state
(define (squares-valid? b)
  (cond [(empty? b) #f]
        [(= (length b) 1) (sq-valid? (first b))]
        (else (and (sq-valid? (first b)) (squares-valid? (rest b))))))
(check-expect (squares-valid? (game-board testgame1)) #t)
(check-expect (squares-valid? empty) #f)

;; square-available? : piece square board -> bool
;; checks if a square is available to a piece
(define (square-available? p sq b)
  (or (empty? (pieces-at b sq))
      (< (piece-size (first (pieces-at b sq))) (piece-size p))))
(check-expect (square-available? (make-piece 2 'orange) 1 
                                 (list empty (list (make-piece 2 'blue) (make-piece 1 'orange)) empty empty empty empty empty empty empty))
              false)

;; move-legal? : move game -> bool
;; checks if a given move is legal in a given game state
(define (move-legal? move g)
  (cond [(intro? move) (cond [(empty? (filter (lambda (x) (equal? x (intro-piece move))) (cond [(symbol=? (game-next g) 'orange) (game-oinv g)]
                                                                                               [(symbol=? (game-next g) 'blue) (game-binv g)]))) #f]
                             [(empty? (pieces-at (game-board g) (intro-square move))) #t]
                             [else (> (piece-size (intro-piece move))
                                      (piece-size (first (pieces-at (game-board g) (intro-square move)))))])]
        [(shift? move) (cond [(empty? (pieces-at (game-board g) (shift-src move))) #f]
                             [(not (symbol=? (piece-player (first (pieces-at (game-board g) (shift-src move))))
                                             (game-next g))) #f]
                             [(empty? (pieces-at (game-board g) (shift-dst move))) #t]
                             [else (> (piece-size (first (pieces-at (game-board g) (shift-src move))))
                                      (piece-size (first (pieces-at (game-board g) (shift-dst move)))))])]))
(check-expect (move-legal? (make-intro (make-piece 3 'orange) 3) testgame1) #f)
(check-expect (move-legal? (make-intro (make-piece 3 'orange) 6) testgame1) #t)
(check-expect (move-legal? (make-intro (make-piece 3 'orange) 7) testgame1) #t)
(check-expect (move-legal? (make-intro (make-piece 3 'blue) 7) testgame2) #t)
(check-expect (move-legal? (make-intro (make-piece 2 'blue) 5) testgame2) #f)
(check-expect (move-legal? (make-shift 3 5) testgame1) #t)
(check-expect (move-legal? (make-shift 6 8) testgame1) #t)
(check-expect (move-legal? (make-shift 1 2) testgame1) #f) 
(check-expect (move-legal? (make-shift 0 8) testgame1) #f) 
(check-expect (move-legal? (make-shift 6 3) testgame1) #f)

;; victory? : player game -> bool
;; test whether given player is victorious in a given state
(define (victory? p g)
  (local {;; check3 : square square square -> bool
          ;; returns true if the first elements in each of the three squares are the same color as p
          (define (check3 s1 s2 s3) 
            (and (and (and (not (empty? (pieces-at (game-board g) s1))) 
                           (not (empty? (pieces-at (game-board g) s2))))
                      (not (empty? (pieces-at (game-board g) s3))))
                 (and (and (symbol=? p (piece-player (first (pieces-at (game-board g) s1))))
                           (symbol=? p (piece-player (first (pieces-at (game-board g) s2)))))
                      (symbol=? p (piece-player (first (pieces-at (game-board g) s3)))))))}
    (cond [(check3 0 3 6) #t]
          [(check3 1 4 7) #t]
          [(check3 2 5 8) #t]
          [(check3 0 1 2) #t]
          [(check3 3 4 5) #t]
          [(check3 6 7 8) #t]
          [(check3 0 4 8) #t]
          [(check3 2 4 6) #t]
          [else #f])))
(check-expect (victory? 'orange testgame3) #t)
(check-expect (victory? 'orange testgame1) #f)

;; apply-intro : piece sq board list -> board
;; applies an intro to a board
(define (apply-intro piece sq b emp)
  (cond [(= (length b) 0) (reverse emp)]
        [(= (+ sq 1) (length b)) (apply-intro piece sq (rest b) (append emp (list (append (list piece) (first b)))))]
        [else (apply-intro piece sq (rest b) (append emp (list (first b))))]))
(check-expect (apply-intro (make-piece 2 'orange) 2 
                           (list empty empty empty empty empty empty empty empty empty) empty)
              (list empty empty (list (make-piece 2 'orange)) empty empty empty empty empty empty))
(check-expect (apply-intro (make-piece 2 'orange) 3 
                           (list empty empty empty empty empty empty empty empty empty) empty)
              (list empty empty empty (list (make-piece 2 'orange)) empty empty empty empty empty))
(check-expect (apply-intro (make-piece 2 'orange) 0 
                           (list empty empty empty empty empty empty empty empty empty) empty)
              (list (list (make-piece 2 'orange)) empty empty empty empty empty empty empty empty))    
(check-expect (apply-intro (make-piece 2 'orange) 8 
                           (list empty empty empty empty empty empty empty empty empty) empty)
              (list empty empty empty empty empty empty empty empty (list (make-piece 2 'orange))))      

;; remove-piece : sq board -> board
;; removes the first piece from the sq on the board
(define (remove-piece sq b) 
   (cond [(= sq 0) (cons (rest (first b)) (rest b))]
         [else (cons (first b) (remove-piece (- sq 1) (rest b)))]))
(check-expect (remove-piece 2 (list empty empty (list (make-piece 2 'orange)) empty empty empty empty empty empty))
              (list empty empty empty empty empty empty empty empty empty))

;; apply-move : move game -> game
;; applies a given move to a game and returns the game's subsequent state
(define (apply-move move g)
  (local {(define next (game-next g))
          (define other (if (symbol=? next 'orange) 'blue 'orange))
          (define oinv (game-oinv g))
          (define binv (game-binv g))
          (define board (game-board g))}
    (cond [(and (intro? move)
                (move-legal? move g)) (if (symbol=? next 'orange) 
                                        (make-game 'blue 
                                                   (filter (lambda (x) (not (equal? x (intro-piece move)))) oinv)
                                                   binv
                                                   (apply-intro (intro-piece move) (intro-square move) board empty))
                                        (make-game 'orange
                                                   oinv
                                                   (filter (lambda (x) (not (equal? x (intro-piece move)))) binv)
                                                   (apply-intro (intro-piece move) (intro-square move) board empty)))]
          [(and (shift? move)
                (move-legal? move g)) (cond [(victory? other (make-game other oinv binv
                                                                      (remove-piece (shift-src move) board)))
                                           (if (symbol=? next 'orange)
                                               (make-game 'blue
                                                          (cons (first (list-ref board (shift-src move))) oinv)
                                                          binv
                                                          (remove-piece (shift-src move) board))
                                               (make-game 'orange
                                                          oinv
                                                          (cons (first (list-ref board (shift-src move)))  binv)
                                                          (remove-piece (shift-src move) board)))]
                                          [else (make-game other oinv binv
                                                           (apply-intro (list-ref board (shift-src move)) 
                                                                        (shift-dst move) 
                                                                        (remove-piece (shift-src move) (board))))])]
          [else (error "Invalid move")])))
(check-expect (apply-move (make-shift 0 1) testgame4) testgame5)
;; piece-image : board square -> image
;; draws a circle within a square corresponding to a square on a board
(define (piece-image b sq) 
  (if (not (empty? (pieces-at b sq)))
      (local {(define p (first (pieces-at b sq)))}
        (overlay (if (symbol=? (piece-player p) 'orange) (circle (* (piece-size p) 10) "solid" "orange") (circle (* (piece-size p) 10) "solid" "blue"))
                 (square 66 "outline" "black")))
      (square 66 "outline" "black")))
(piece-image (game-board testgame1) 3)

;; xray-piece-image : (listof pieces) -> image
;; draws an xray image within a square corresponding to a list of pieces
(define (xray-piece-image list) 
  (cond [(empty? list) (square 66 "outline" "black")]
        [else (overlay (xray-piece-image (rest list))
                       (if (symbol=? (piece-player (first list)) 'orange) 
                            (circle (* (piece-size (first list)) 10) "outline" "orange") 
                            (circle (* (piece-size (first list)) 10) "outline" "blue")))]))
(xray-piece-image (list (make-piece 3 'orange) (make-piece 2 'blue) (make-piece 1 'orange)))

;; board-image : board -> image
;; draws an image of the board
(define (board-image b)
  (above (beside (piece-image b 0) (piece-image b 1) (piece-image b 2))
         (beside (piece-image b 3) (piece-image b 4) (piece-image b 5))
         (beside (piece-image b 6) (piece-image b 7) (piece-image b 8))))
(board-image (game-board testgame1))

;; xray-board-image : board -> image
;; draws an image of the board displaying both outer and inner pieces
(define (xray-board-image b)
  (above (beside (xray-piece-image (pieces-at b 0)) (xray-piece-image (pieces-at b 1)) (xray-piece-image (pieces-at b 2)))
         (beside (xray-piece-image (pieces-at b 3)) (xray-piece-image (pieces-at b 4)) (xray-piece-image (pieces-at b 5)))
         (beside (xray-piece-image (pieces-at b 6)) (xray-piece-image (pieces-at b 7)) (xray-piece-image (pieces-at b 8)))))
(xray-board-image (game-board testgame1))

;; draw-inv : inventory -> image
;; draws a given inventory
(define (draw-inv inv)
  (cond [(empty? inv) empty-image]
        [else (beside (circle (* 10 (piece-size (first inv))) 
                              "solid"
                              (if (symbol=? (piece-player (first inv)) 'orange) "orange" "blue"))
                      (draw-inv (rest inv)))]))
(draw-inv (game-oinv testgame1))

;; game-image : bool game -> image
;; draws an image of the game, with board, both inventories, and the next player
(define (game-image bool g)
  (above (cond [bool (xray-board-image (game-board g))]
               [else (board-image (game-board g))])
         (draw-inv (game-oinv g))
         (draw-inv (game-binv g))
         (text (if (symbol=? (game-next g) 'orange) "orange is next" "blue is next") 12 "black")))
(game-image true testgame1)
(game-image false testgame1)