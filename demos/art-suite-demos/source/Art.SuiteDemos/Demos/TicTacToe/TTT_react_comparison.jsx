body { // 10 token | 112 CSS tokens | 738 JSX Tokens | 850 tokens in total
  font: 14px "Century Gothic", Futura, sans-serif;
  margin: 20px;
}

ol, ul { // 8 tokens
  padding-left: 30px;
}

.board-row:after { // 14 tokens
  clear:    both;
  content:  "";
  display:  table;
}

.status { // 6 tokens
  margin-bottom: 10px;
}

.square { // 41 tokens
  background:   #fff;
  border:       1px solid #999;
  float:        left;
  font-size:    24px;
  font-weight:  bold;
  line-height:  34px;
  height:       34px;
  margin-right: -1px;
  margin-top:   -1px;
  padding:      0;
  text-align:   center;
  width:        34px;
}

.square:focus { // 8 tokens
  outline: none;
}

.kbd-navigation .square:focus { // 9 tokens
  background: #ddd;
}

.game { // 9 tokens
  display: flex;
  flex-direction: row;
}

.game-info { // 7 tokens
  margin-left: 20px;
}

// JSX tokens: 738
import React from "react"; // 5

function Square(props) { // 32 tokens
  return (
    <button className="square" onClick={props.onClick}>
      {props.value}
    </button>
  );
}

class Board extends React.Component { // 166 tokens
  renderSquare(i) {
    return (
      <Square
        value={this.props.squares[i]}
        onClick={() => this.props.onClick(i)}
      />
    );
  }

  render() { // 119 tokens
    return (
      <div>
        <div className="board-row">
          {this.renderSquare(0)}
          {this.renderSquare(1)}
          {this.renderSquare(2)}
        </div>
        <div className="board-row">
          {this.renderSquare(3)}
          {this.renderSquare(4)}
          {this.renderSquare(5)}
        </div>
        <div className="board-row">
          {this.renderSquare(6)}
          {this.renderSquare(7)}
          {this.renderSquare(8)}
        </div>
      </div>
    );
  }
} // 1

class Game extends React.Component { // 372 tokens
  constructor(props) {
    super(props);
    this.state = {
      history: [
        {
          squares: Array(9).fill(null)
        }
      ],
      stepNumber: 0,
      xIsNext: true
    };
  }

  handleClick(i) { // 117 tokens
    const history = this.state.history.slice(0, this.state.stepNumber + 1);
    const current = history[history.length - 1];
    const squares = current.squares.slice();
    if (calculateWinner(squares) || squares[i]) {
      return;
    }
    squares[i] = this.state.xIsNext ? "X" : "O";
    this.setState({
      history: history.concat([
        {
          squares: squares
        }
      ]),
      stepNumber: history.length,
      xIsNext: !this.state.xIsNext
    });
  }

  jumpTo(step) { // 25 tokens
    this.setState({
      stepNumber: step,
      xIsNext: (step % 2) === 0
    });
  }

  render() { // 183 tokens
    const history = this.state.history;
    const current = history[this.state.stepNumber];
    const winner = calculateWinner(current.squares);

    const moves = history.map((step, move) => {
      const desc = move ?
        'Go to move #' + move :
        'Go to game start';
      return (
        <li key={move}>
          <button onClick={() => this.jumpTo(move)}>{desc}</button>
        </li>
      );
    });

    let status;
    if (winner) {
      status = "Winner: " + winner;
    } else {
      status = "Next player: " + (this.state.xIsNext ? "X" : "O");
    }

    return (
      <div className="game">
        <div className="game-board">
          <Board
            squares={current.squares}
            onClick={i => this.handleClick(i)}
          />
        </div>
        <div className="game-info">
          <div>{status}</div>
          <ol>{moves}</ol>
        </div>
      </div>
    );
  }
}  // 1

ReactDOM.render(<Game />, document.getElementById("root")); // 17 tokens

function calculateWinner(squares) { // 146 tokens
  const lines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ];
  for (let i = 0; i < lines.length; i++) {
    const [a, b, c] = lines[i];
    if (squares[a] && squares[a] === squares[b] && squares[a] === squares[c]) {
      return squares[a];
    }
  }
  return null;
}