class EvaluatorTestCases:
    expressions = [
        ("1 2 + 2.5 * 2 5 SUM", 14.5, float, 3),
        ("1 2 3 SUM 4 5 SUM 6 7 SUM", sum(range(8)), int, 3),
        ("1 2 3 SUM 4 5 SUM 6 7 SUM 8.5 *", sum(range(8)) * 8.5, float, 4),
    ]

    not_ok = [
        """
            void test(){
                int a; int b; a = int; b = int; int a /* scope violation*/
            }
        """,
        """
            void test(){
                int a; int b; {
                    int a; int b; {
                        int c; int a;
                        int q; int q;
                    }
                }
            }
        """,
        """void a(){ }; void a(){ }""",
        """int i; i = str""",
        """int b; int b;"""
    ]

    ok = [
        """
            void test(){
                int a; int b; a = int; b = int;
            }
        """,
        """
            void test(){
                int a; int b; a = int; b = int; {
                    int a; int b; {
                        int d; int e;
                    }
                }
            }
        """,
        """str i; i = str""",
        """int b; int c;"""
    ]
