scriptName NihSldUtil hidden
{Utility functions used for Spell Learning and Discovery}

int function CalculateNextCapacity(int requestedCapacity, int from = 8, int delta = 64) global
    int current = from;
    while (current < 128 && requestedCapacity > current)
        current *= 2
    endWhile

    if requestedCapacity > current
        while requestedCapacity > current
            current += delta
        endWhile
    endIf
    return current
endFunction