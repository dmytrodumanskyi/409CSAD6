// ============================================================================
// tb_spi.v — тестбенч для SPI Master + SPI Slave (варіант 6)
// Генерує такт 50 МГц і скидання, передає кілька байтів у повному дуплексі
// та автоматично перевіряє, що:
//   - Slave прийняв саме той байт, який передав Master (лінія MOSI);
//   - Master прийняв саме той байт, який передав Slave (лінія MISO).
// Результат: файл часових діаграм tb_spi.vcd і підсумок у консолі.
// ============================================================================
`timescale 1ns/1ps
module tb_spi;

    reg        clk = 1'b0;
    reg        rst = 1'b1;
    reg        start = 1'b0;
    reg  [7:0] m_tx = 8'h00;   // що передає Master
    reg  [7:0] s_tx = 8'h00;   // що передає Slave
    wire [7:0] m_rx, s_rx;
    wire       busy, done, s_valid;
    wire       sclk, mosi, miso, cs_n;

    always #10 clk = ~clk;     // 50 МГц (період 20 нс)

    spi_master #(.CLK_DIV(5)) u_master (
        .clk(clk), .rst(rst), .start(start), .tx_data(m_tx),
        .rx_data(m_rx), .busy(busy), .done(done),
        .sclk(sclk), .mosi(mosi), .miso(miso), .cs_n(cs_n)
    );

    spi_slave u_slave (
        .clk(clk), .rst(rst), .sclk(sclk), .cs_n(cs_n), .mosi(mosi),
        .miso(miso), .tx_data(s_tx), .rx_data(s_rx), .rx_valid(s_valid)
    );

    // фіксуємо байт, прийнятий Slave-ом
    reg [7:0] s_got;
    always @(posedge clk) if (s_valid) s_got <= s_rx;

    integer errors = 0;
    integer tests  = 0;

    // одна транзакція: Master відправляє mt, Slave відповідає st
    task transfer(input [7:0] mt, input [7:0] st);
        begin
            @(negedge clk);
            m_tx  = mt;
            s_tx  = st;
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;
            @(posedge done);
            @(negedge clk);
            tests = tests + 1;
            if (m_rx === st && s_got === mt)
                $display("[%0t ns] PASS  Master->Slave 0x%02h (got 0x%02h)   Slave->Master 0x%02h (got 0x%02h)",
                         $time, mt, s_got, st, m_rx);
            else begin
                errors = errors + 1;
                $display("[%0t ns] FAIL  Master->Slave 0x%02h (got 0x%02h)   Slave->Master 0x%02h (got 0x%02h)",
                         $time, mt, s_got, st, m_rx);
            end
            repeat (10) @(negedge clk);    // пауза між байтами
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_spi);
        repeat (5) @(negedge clk);
        rst = 1'b0;
        repeat (5) @(negedge clk);

        transfer(8'hA5, 8'h3C);
        transfer(8'h3C, 8'hA5);
        transfer(8'hFF, 8'h00);
        transfer(8'h00, 8'hFF);
        transfer(8'h81, 8'h7E);
        transfer(8'h5A, 8'hC3);

        if (errors == 0)
            $display("RESULT: ALL %0d TESTS PASSED", tests);
        else
            $display("RESULT: %0d OF %0d TESTS FAILED", errors, tests);
        $finish;
    end

    // захист від зависання
    initial begin
        #200000;
        $display("RESULT: TIMEOUT");
        $finish;
    end

endmodule
